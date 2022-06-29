// -------------------------------------------------------------------------------------
// Hong Jie Yang | yangh59 | 400070071 | April 5 2019
// -------------------------------------------------------------------------------------
// Using the ADXL337 accelerometer, record the relative angle to x and y axis using ADCs
// and a series of linear approximation. Then display the x-axis angle in either a BCD
// or linear LED display. Seriall transmit the results to Matlab where it will be displayed

#include <hidef.h>      /* common defines and macros */
#include "derivative.h"  /* derivative information */
#include "SCI.h"

// -------------------------------------------------------------------------------------
// Declare Global Variables
// -------------------------------------------------------------------------------------
unsigned short on;        // Start (on = 1) or stop (on = 0) serial communication
unsigned short mode;    // LED display mode (mode = 0 for BCD and mode = 1 for linear bar 

unsigned int val_x;   // Analog input from accelerometer for x-axis
unsigned int angle_x; // Angle calculation of accelerometer for x-axis
unsigned int val_y;   // Analog input from accelerometer for y-axis
unsigned int angle_y; // Angle calculation of accelerometer for y-axis
unsigned int val_z;

unsigned short Vmax_x;    // Maximum digital input for x-axis
unsigned short Vmin_x;    // Minimum digital input for x-axis
unsigned short Vmax_y;    // Maximum digital input for y-axis
unsigned short Vmin_y;    // Minimum digital input for y-axis

unsigned int Vr1_x;     // Threshold input for 1st and 2nd range approximations ([Vmin_x Vr1_x Vr2_x Vmax_x])
unsigned int Vr2_x;     // Threshold input for 2nd and 3rd range approximations (Form ranges for 3 approximations)

unsigned short Vr1_y;     // Threshold input for 1st and 2nd range approximations ([Vmin_y Vr1_y Vr2_y Vmax_y])
unsigned short Vr2_y;     // Threshold input for 2nd and 3rd range approximations (Form ranges for 3 approximations)

// -------------------------------------------------------------------------------------
// Function Prototypes
// -------------------------------------------------------------------------------------
void OutCRLF();

// -------------------------------------------------------------------------------------
// Main Function
// -------------------------------------------------------------------------------------
void main(void) {		

  // -------------------------------------------------------------------------------------
  // Initialize Global Variables
  // -------------------------------------------------------------------------------------
  on = 0;       // Start out not collecting data
  
  // x-axis
  Vmax_x = 2465;  // Maximum ADC input
  Vmin_x = 2035;  // Minimum ADC input
  Vr1_x = 2250;   // (0.5 --> 30 degrees)
  Vr2_x = 2407;   // (0.866 --> 60 degrees) 
  
   // y-axis
  Vmax_y = 3090;   // Maximum ADC input
  Vmin_y = 2810;  // Minimum ADC input
  Vr1_y = 2950;   // (0.5 --> 30 degrees)
  Vr2_y = 3052;   // (0.866 --> 60 degrees) 

  // -------------------------------------------------------------------------------------
  // Configure Bus Clock Speed to 4 MHz
  // -------------------------------------------------------------------------------------
  CPMUPROT = 0x26;    // Disable clock write protections
  CPMUCLKS = 0x80;    // PLLSEL = 1 (Select phase locked loop clock as clock source)
  CPMUOSC = 0x80;     // OSCE = 1 (Select Oscillator (8MHz) as clock reference for VCOCLOCK)
  
  CPMUREFDIV = 0x80;  // b[7:6] = REFFRQ[1:0] = 10 (6MHz < f_REF <= 12MHz)
                      // b[3:0] = REFDIV[3:0] = 0000 (f_REF = f_OSC / (REFDIV + 1) = 8MHz)
                      // CPMUREFDIV = 0b[1000 0000] = 0x80
                    
  CPMUSYNR = 0x02;    // b[7:6] = VCOFRQ[1:0] = 00 (32MHz <= f_VCO <= 48MHz)
                      // b[5:0] = SYNDIV[5:0] = 00010 (SYNDIV = 2)
                      // f_VCO = 2 * f_REV * (SYNDIV + 1) = 6 * f_REV = 48MHz
                      // CPMUSYNR = 0b[0000 0010] = 0x02
                    
  CPMUPOSTDIV = 0x05; // b[4:0] = POSTDIV[4:0] = 0101 (POSTDIV = 5)
                      // f_PLL = f_VCO / (POSTDIV + 1) = f_VCO / 6 = 8MHz 
  
  while (CPMUFLG_LOCK == 0) {} // Wait for PLL to engage
                               // Bus Clock = f_PLL / 2 = 4MHz
  
  CPMUPROT = 0x01;    // Renable clock write protections

  // -------------------------------------------------------------------------------------
  // Configure Port AD for GPIO
  // -------------------------------------------------------------------------------------
  DDR1AD = 0x1F;    // PAD[4:0] = 1 (Output) (AN5 takes priority over PAD5)
                    // DDR1AD = 0b[0001 1111] = 0x1F     
                                 
  DDR0AD = 0xFF;    // PAD[11:8] = 1 (Output)
  ATDDIEN = 0x00C0; // b[7:0] = IEN[7:0] = 1100 0000 = 0xC0 
  PER1AD = 0xC0;    // b[7:0] = PER1ADx = 1100 0000 = 0xC0 (Enable pull up resistor)

  // -------------------------------------------------------------------------------------
  // Configure Analog to Digital Channels (AN5), (AN6), and (AN7)
  // -------------------------------------------------------------------------------------
  // ATDCTL2 is not required due to polling methodology

  ATDCTL0 = 0x07;   // b[3:0] = WRAP3|WRAP2|WRAP1|WRAP0 = 0111 (Select AN7 for wraparound after converting)

	ATDCTL1 = 0x61;		// b[6:5] = SRES[1:0] = 11 (Selects for 16-bit data)
	                  // b[3:0] = ETRIGCH[3:0] = 0001 (Selects AN1 for External Trigger Channel)
	                  // ATDCTL1 = 0b[0110 1111] = 0x41
	                  
	ATDCTL3 = 0x98;		// b[7] = DJM = 1 (Right justified result registers)
	                  // b[6:3] = S8C|S4C|S2C|S1C = 0011 (Conversion length of 3 | Read AN5, AN6, and AN7)
	                  // b[2] = FIFO = 0 (Non-Fifo mode)
	                  // ATDCTL3 = 0b[1001 0000] = 0x98
	                  
	ATDCTL4 = 0x01;		// b[7:5] = SMP2|SMP1|SMP0 = 000 (Sample Time Select of 4 for minimum value)
	                  // b[4:0] = PRS[4:0] = 00001 (Prescaler of 1)
	                  // ATD clock = 4MHz / [2 * (1 + 1)] = 1MHz (Maximum rate)  
                    // ATDCTL4 = 0b[0000 0001] = 0x01
  
	ATDCTL5 = 0x35;		// b[5] = SCAN = 1 (Continuous conversion sequences)
	                  // b[4] = MULT = 1 (Multi channel conversion)
	                  // b[3:0] = CD|CC|CB|CA = 0101 (Channel 5)
                    // ATDCTL5 = 0b[0011 0101] = 0x35
     
  // -------------------------------------------------------------------------------------
  // Configure Interrupts
  // -------------------------------------------------------------------------------------
  TSCR1 = 0x90; // b[7] = TEN = 1 (Enable the timer)
                // b[6:5] = TSWAI/TSFRZ = 00 (Allow timer modules to run in both wait and freeze modes)
                // b[4] = TFFCA = 1 (Enable timer fast flag clear all)
                // b[3] = PRNT = 0 (Enable legacy timer and use PR0, PR1 and PR2 of TSCR2 for prescaler) 
                // TSCR1 = 0b[1001 0000] = 0x90 
                
  TSCR2 = 0x02; // b[7] = TOI = 0 (Inhibit timer overflow)
                // b[2:0] = PR2|PR1|PR0 = 010 (Prescaler of 4 | Timer CLK = 4 MHz / 4 = 1 MHz)
                    
  TIOS = 0xFC;  // b[1:0] = IOS1|IOS0 = 00 (Set channels 0 and 1 as input capture) 
                   
  PERT = 0x02;  // b[1:0] = PERT1|PERT0 = 11 (Enable pull up resistor for channels 0 and 1)

  TCTL3 = 0x00; // Unused input channels
  TCTL4 = 0x0A; // b[3:0] = EDG1B|EDG1A|EDG0B|EDG0A = 1010 (EDGnB|EDGnA = 10 for capture on falling edge only)     
   
  TIE = 0x03;   // b[1:0] = 11 (Enable timer interrupt for channel 0 and 1)        
     
  // -------------------------------------------------------------------------------------
  // Configure Autonomous Periodical Interrupts for Sampling
  // -------------------------------------------------------------------------------------
  //CPMUAPICTL = 0x80 ; // b[7] = APICLK = 1 (Use bus clock as source = 4 MHz)
                    
  //CPMUAPIRH = 0xFF ;  // Period = 2 * (APIR[15:0] + 1) * Bus Clock period 
  //CPMUAPIRL = 0xFF ;  // 1/960 = 2 * (APIR[15:0] + 1) * (1 / 4e6) --> APIR[15:0] = 2082 = 0x0822 (Max sampling speed)
                      // APIR[15:0] = 0xFF = 131072 * 1/BusCLK = 32.768s = 30.52 Hz  
                      // APIR[15:8] = CMPUAPIRH | APIR[7:0] = CMPUAPIRL
 
 
  CPMUAPICTL = 0x80 ;   // b[7] = APICLK = 1 (Use bus clock as source = 24 MHz)
  
  // Test @ 500 Hz                   
  //CPMUAPIRH = 0x5D ;    // Period  = 2 * (APIR[15:0] + 1) * Bus Clock period 
  //CPMUAPIRL = 0xC0 ;    // APIR[15:0] = 0x0BBC --> 2 * 24000 * 1/BusCLK = 2e-3 s = 500 Hz
                        
  // Run @ 2 kHz                      
  CPMUAPIRH = 0x10 ;    // Period  = 2 * (APIR[15:0] + 1) * Bus Clock period
  CPMUAPIRL = 0x70 ;    // APIR[15:0] = 0x1770 --> 2 * 6000 * 1/BusCLK = 5e-4 s = 2 kHz

  CPMUAPICTL_APIFE = 1; // b[2] = APIFE = 1 (Enable autonomus periodical interrupts feature) (Enable the timer)
  CPMUAPICTL_APIE = 1; // b[1] = APIE = 1 (Enable autonomus periodical interrupts) (Enable the interrupt)
 
  EnableInterrupts;   // Enable interrupts for ESDX
   
  // -------------------------------------------------------------------------------------
  // Setup Serial Communication Interface
  // ------------------------------------------------------------------------------------- 
  SCI_Init(250000); // Baud Divisor = 13 for 19200 Hz (Fastest SCI communication rate possible) 
  //SCI_Init(19200); // Baud Divisor = 13 for 19200 Hz (Fastest SCI communication rate possible) 
  DDRJ = 0x01;
  PTJ = 0x00; 

  // -------------------------------------------------------------------------------------
  // Infinite for loop
  // ------------------------------------------------------------------------------------- 
  for(;;){
  } // end of for loop 
}
          
// -------------------------------------------------------------------------------------
// Interrupt Service Routines
// -------------------------------------------------------------------------------------
// Interrupt service routine for TIC channel 0 (Vtimch0)
// Button used to stop and start data collection
interrupt VectorNumber_Vtimch0 void ISR_Vtimch0(void)
{
  unsigned int temp;
  
  on ^= 1; // Toggle ON state
  PTJ ^= 1;
    
  temp = TC0; // Clear flag to allow new TIC interrupt

} // Vtimch0 interrupt service routine

// -------------------------------------------------------------------------------------
// Interrupt service routine for TIC channel 1 (Vtimch1)
// Button used to switch modes
interrupt VectorNumber_Vtimch1 void ISR_Vtimch1(void)
{
  unsigned int temp;  
  
  mode ^= 1; // Toggle mode
  
  temp = TC1; // Clear flag to allow new TIC interrupt
  
} // Vtimch1 interrupt service routine 

// -------------------------------------------------------------------------------------
// Interrupt service routine for autonomous periodic interrupts
// Sample the acceleromter at the desired rate (1 KHz)
interrupt VectorNumber_Vapi void Sample_ISR(void) 
{
  if (on == 1) // Transmit data
  {  
    val_x = ATDDR0; // Get x-axis digital reading
    val_y = ATDDR1; // Get y-axis digital reading
    val_z = ATDDR2; // Get z-axis digital reading
    
    //SCI_OutUHex(val_x); // Output result to Matlab
    //SCI_OutString(" | ");
    //SCI_OutUHex(val_y);
    //SCI_OutString(" | ");
    //SCI_OutUHex(val_z);
    
    SCI_OutChar(val_x / 255);
    SCI_OutChar(val_x % 255);
    SCI_OutChar(val_y / 255);
    SCI_OutChar(val_y % 255);
    SCI_OutChar(val_z / 255);
    SCI_OutChar(val_z % 255);

  } 
  else // Pause Matlab application
  {
    SCI_OutChar(0);
    SCI_OutChar(0);
    SCI_OutChar(0);

  }// end of if
  
  CPMUAPICTL_APIF = 1; // Reset API flag for new interrupt
} // Autonomous periodic interrupt service routine

// -------------------------------------------------------------------------------------
// Functions
// -------------------------------------------------------------------------------------
void OutCRLF(void) {

  SCI_OutChar(CR);
  SCI_OutChar(LF);

}