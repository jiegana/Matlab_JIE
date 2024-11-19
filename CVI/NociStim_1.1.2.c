/*PROGRAM CONTROLS THE TRANSCUTANEAL ELECTRIC STIMULATOR (Digitimer DS7A)
THE STIM ONLY SOFTWARE IS INTENDED TO DO PSYCHOPHYSIC EXPERIMENTS
IT IS ALSO DESIGNED TO BE ATTACHED TO THE EEG SOFTARE IN A NEAR FUTURE 

*****************GENERAL DESCRIPTION********************

**Definitions**
Number of Trains = Number of times a stimulus will be triggered. Default = 100
ISI between (ms) = miliseconds that will pass between stimuli. Minimum = 500, Maximum 10.000 (10 sec)

**Experimental assumptions**


**Graphical User Interface**


**********************************************************************************************************************	
	Laboratorio de Neurosistemas
	Facultad de Medicina
	Universidad de Chile
	
	Jos� Ignacio Ega�a T. (Plastikfaith) 2024 = jiegana@uchile.cl
	
		Uses code written by Daniel Rojas L. and Gonzalo Rivera L.
	
**********************************************************************************************************************

First Stable Version: v1.0.1 = 21/11/2023
Current Version = v1.1.1 = 15/10/2024 
Source Code File Version = 1.1.1

**********************************************************************************************************************

RELEASE NOTES

*** v1.0.1 ***
Stim_only2.uir
NociStim_1.0.1.c
Stim_only.h
NociStim.prj

First stable version
Just minor changes over the Stim Only project in order to make NociStim available for RG's FONDECYT requirements:
Number of pulses (Number of trains)
Inter Stimulus Interval betweeem pulses (ISI between) 


*** v1.1 ***
Stim_only2.uir
NociStim_1.1.c
Stim_only.h
NociStim.prj

Correct naming of developer files (.c)

*** v1.1.1 ***
Stim_only2.uir
NociStim_1.1.1.c
Stim_only.h
NociStim.prj

A lot of no used code was deleted. For recovery go to previous versions.
IMPORTANT: Changes have been made to the sleep times in CoreTask to prevent TTL on/off transitions from happening 
as fast as the system (CPU) allows. These rapid transitions could cause the on/off states to go undetected 
by low sampling frequencies.
Previously
TTL ON
Sleep (10)
TTL OFF (fast transition)
TTL ON
Sleep (90)
TTL OFF

Now
TTL ON
Sleep (5)
TTL OFF
Sleep(5)
TTL ON
Sleep (90)
TTL OFF


*** v1.1.2 ***
Stim_only2.uir
NociStim_1.1.2.c
Stim_only.h
NociStim.prj

Contains optimizations suggested by ChatGPT (GPT-4, accessed Oct 28th 2024). See end of code.
*/

#include <windows.h>
#include "toolbox.h"
#include <analysis.h>
#include <utility.h>
#include <ansi_c.h>
#include <NIDAQmx.h>
#include <cvirte.h>
#include <userint.h>
#include "Stim_only.h"

// Task Handles
TaskHandle Pulsos_Stim;

// Functions
int CreateTask(void);
int CoreTask(void);
int wait(double delay);
int SaveData(void);
int GenSeq(void);
int GetRand(int min, int max);
void ClearSalio(void);
int* dec2bin(int);


// Files
//FILE *stm_file;

// Variables
int panel2, panel3, panel4, GO = 0, count = 0;
int Noftrains, ISIwithin, fileok = 0, overwrite = 0;
float ISIbetw;
uInt8 ttlstate[8];
uInt8 ttloff[8] = {0};
int32 spcw;
char status_name[64];

// Main
int main(int argc, char* argv[]) {
    if (InitCVIRTE(0, argv, 0) == 0) return -1;  // Out of memory
    if ((panel2 = LoadPanel(0, "Stim_only2.uir", PANEL_2)) < 0) return -1;
    SetPanelAttribute(panel2, ATTR_TOP, 72);
    SetPanelAttribute(panel2, ATTR_LEFT, 1000);
    DisplayPanel(panel2);
    CreateTask();
    RunUserInterface();
    return 0;
}



// CoreTask
// This is the principal function. Write Digital Lines to de Device (NI USB-6218) that will work as triggers
// of the stimulator (Digitimer DS 7A)

int CoreTask(void) {
    for (int j = 0; j < 1; j++) {
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttlstate, &spcw, 0);
        Sleep(5);
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttloff, &spcw, 0);
        Sleep(5);
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttlstate, &spcw, 0);
        Sleep(90);
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttloff, &spcw, 0);
        Sleep(ISIbetw - 100);
    }
    return 0;
}

// StartStim
// This functions collect inputs from controls in panel2, stores them and starts timer.
int CVICALLBACK Start_stim (int panel, int control, int event,
		void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		char pausa;

		case EVENT_COMMIT:
			
/***************************************/
//			Biosemi pause off		   //
/***************************************/		
		/*		Biosemi release pause with TTL = 201	*/
		/*		The pause release number is writen in Biosemi's config file	*/
//		ttldemo = dec2bin(201);

/*		for(i = 0; i<8; i++){
			ttlstate[i] = (uInt8)(ttldemo[i]);
		}
		DAQmxWriteDigitalLines (Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttlstate, &spcw, 0);
		
		Sleep (100);
				//ttlstate[0] = 0;
		DAQmxWriteDigitalLines (Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttloff, &spcw, 0);
		
		
			if (fileok != 1){
				MessagePopup ("NO FILE", "Please Create Session's File");
				GO = 0;
				break;
			}*/
			//GO = 1;
			GetSystemTime (&h1, &m1, &s1);
			
			GetCtrlVal (panel2, PANEL_2_NUM_TRAINS, &Noftrains);
			GetPanelAttribute (panel2, ATTR_BACKCOLOR, &start_color);
			GetPanelAttribute (panel2, ATTR_TITLE, ori_title);		
			GetCtrlVal (panel2, PANEL_2_NUMERIC_2, &ISIbetw);
	
			////////////////////////////////			
			// Asignation of timer interval//
			////////////////////////////////  
			tempi = SetCtrlAttribute (panel2, PANEL_2_TIMER_STIM, ATTR_INTERVAL, ISIbetw/1000);
			GO = 1;

// If any of the previous process is not acomplished, GO = 0. So here program continues only
// if GO = 1;
			//printf("\n\t%d", GO);
			if(GO == 1){
				timer_count = 0; 
				SetCtrlAttribute (panel2, PANEL_2_TIMER_STIM, ATTR_ENABLED, 1);
				SetPanelAttribute (panel2, ATTR_BACKCOLOR, VAL_DK_GREEN);
				sprintf(status_name,"Running");
				SetPanelAttribute (panel2, ATTR_TITLE, status_name);
				// Show first and 2nd Stimulus to allow the experimenter to setup DS7A
//				SetCtrlVal (panel2, PANEL_2_CURRENT, sequence[0]);
//				SetCtrlVal (panel2, PANEL_2_NEXT, sequence[timer_count+1]);
			}
			else {
				MessagePopup ("Error", "Please Check Protocol and/or Session's File");
				break;
			}
			
			//DAQmxCreateCOPulseChanTime (Pulsos_Stim, "Dev2/ctr0", "Stim_control", DAQmx_Val_Seconds, DAQmx_Val_Low, 2, 1, 1); 
			 //err1=DAQmxStartTask (Pulsos_Stim);
			 //printf("err1 = %d\n",err1);
			 

			break;
	}
	return 0;
}

//
//				QUIT
//

int CVICALLBACK QuitCallback (int panel, int control, int event,
		void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			DAQmxStopTask (Pulsos_Stim); 
	
			QuitUserInterface (0);
			break;
	}
	return 0;
}

int CVICALLBACK stop_stim (int panel, int control, int event,
		void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			if (GO == 1){	  // Check Start has been pressed
				GetCtrlVal (panel2, PANEL_2_PAUSE, &pausestate);
				//printf("\npausestate = %d\n", pausestate);
			
				if (pausestate == 1){
					SetPanelAttribute (panel2, ATTR_BACKCOLOR, VAL_PANEL_GRAY);
					//sprintf(status_name,"Paused");  
					SetPanelAttribute (panel2, ATTR_TITLE, status_name);
					SetCtrlAttribute (panel2, PANEL_2_TIMER_STIM, ATTR_ENABLED, 0);  
				}
				else if (pausestate == 0){
					
					SetPanelAttribute (panel2, ATTR_BACKCOLOR, VAL_DK_GREEN);
					//sprintf(status_name,"Running");
					SetPanelAttribute (panel2, ATTR_TITLE, status_name);	 
					SetCtrlAttribute (panel2, PANEL_2_TIMER_STIM, ATTR_ENABLED, 1);
				}
			}
						
			else {
				MessagePopup ("WARNING!", "Start Stimulation before pause it"); 
				SetCtrlVal (panel2, PANEL_2_PAUSE, 0);
			}
			break;
	}
	return 0;
}
//////////////////////////////////////////////
/*					TIMER					*/
//////////////////////////////////////////////
// Timer allows CoreTask to execute.
// Paused in task is controlled by pausing the timer

int CVICALLBACK timer_stim_click (int panel, int control, int event,
		void *callbackData, int eventData1, int eventData2)
{
	//char pausa;
	switch (event)
	{
		case EVENT_TIMER_TICK:
			if (timer_count <Noftrains){
				//printf("\nNoftrains = %d\nISIbetw = %d\nISIwithin = %d",Noftrains,ISIbetw,ISIwithin);
				GetCtrlAttribute (panel2, PANEL_2_TIMER_STIM, ATTR_INTERVAL, &TI);
//				printf ("\n%d",timer_count);
				SetCtrlVal (panel2, PANEL_2_CURRENT, timer_count+1);
//				SetCtrlVal (panel2, PANEL_2_NEXT, sequence[timer_count+1]); 
				
//              Stimulus will be encoded in a 2 numers code (xx)
//				First numer:	Stimulus intensity (ranging from 1 to 4)
//				Second number:	Always 1 because PFI4 (pin 6 in NI USB-6218 card) will trigger Digitimer DS7A
//				seqx10 transform intensity in the 2 numbers code described above				
				
				seqx10 = 33;
				
				ttldemo = dec2bin(seqx10);
				 //printf("\n%d\n",seqx10);
				for(i = 0; i<8; i++){
					ttlstate[i] = (uInt8)(ttldemo[i]);
				}
/*				for(i = 7; i >= 0; i--){
					printf("i = %d\tttldemo = %d\tttlstate = %d\n", i,ttldemo[i],ttlstate[i]);
				}*/  
				
				////////////////////	
				//	Run CoreTask  //
				////////////////////
					CoreTask();
				
				timer_count++;
			}
				else if (timer_count == Noftrains){
					//////////////////
					//	Write File	//
					//////////////////
					//WrtFile();     
					
					SetCtrlAttribute (panel2, PANEL_2_TIMER_STIM, ATTR_ENABLED, 0); 
					SetPanelAttribute (panel2, ATTR_BACKCOLOR, start_color);
					sprintf(status_name,"Stimulation");
					SetPanelAttribute (panel2, ATTR_TITLE, ori_title);

					timer_count = 0;
					GO = 0;
					MessagePopup ("STIMULATION ENDED", "Done");  
					/*for(i=0;i<80;i++){
						printf("\n%d", sequence[i]);
					}*/
				}
				
			
			break;
	}
	return 0;
}

int CreateTask(void) {
    statusPS = DAQmxCreateTask("Pulsos_Stim", &Pulsos_Stim);
    DAQmxCreateDOChan(Pulsos_Stim, "Dev1/port1/line0:7", "", DAQmx_Val_ChanPerLine);
    return statusPS;
}


int CVICALLBACK cancel_sd (int panel, int control, int event,
		void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
		DisplayPanel (panel2);
		HidePanel (panel3);

			break;
	}
	return 0;
}


// SaveData
// Not Used so far
int SaveData(void)
{
	GetSystemTime (&h2, &m2, &s2);
	GetSystemDate (&mes, &dia, &anio);
	return(0);
}

// Random number generator from http://faq.cprogramming.com/cgi-bin/smartfaq.cgi?answer=1042005782&id=1043284385

// GetRand Optimized
int GetRand(int min, int max) {
    static int seeded = 0;
    if (!seeded) {
        srand(time(NULL));
        seeded = 1;
    }
    return rand() % (max - min + 1) + min;
}


/////////////////////////////////////////////////
//			Decimal to Binary Converter		   //
/////////////////////////////////////////////////
/* This function coverts a decimal numer to its nibary representation. It is desigmed to work with one byte = 8 bits.
In other words, it only works with numbers from 0 to 255

Examples

input = 1
output = 00000001

input = 21
output = 00010101

input = 64
output = 01000000

It is designed to control output paralel port to write stimuli identity in a port and send it to EEG (Biosemi)*/

// Decimal to Binary Optimized with Direct Lookup
int* dec2bin(int c) {
    static int elbin[8];
    for (int i = 7; i >= 0; i--) {
        elbin[i] = (c & (1 << i)) ? 1 : 0;
    }
    return elbin;
}

///////////////////////////////////
////	ChatGPT Suggestions		///
//////////////////////////////////

/*
#include <windows.h>
#include "toolbox.h"
#include <analysis.h>
#include <utility.h>
#include <ansi_c.h>
#include <NIDAQmx.h>
#include <cvirte.h>
#include <userint.h>
#include "Stim_only.h"

// Task Handles
TaskHandle Pulsos_Stim;

// Functions
int CreateTask(void);
int CoreTask(void);
int wait(double delay);
int SaveData(void);
int GenSeq(void);
int GetRand(int min, int max);
void ClearSalio(void);
int* dec2bin(int);

// Variables
int panel2, panel3, panel4, GO = 0, count = 0;
int Noftrains, ISIwithin, fileok = 0, overwrite = 0;
float ISIbetw;
uInt8 ttlstate[8];
uInt8 ttloff[8] = {0};
int32 spcw;
char status_name[64];

// Main
int main(int argc, char* argv[]) {
    if (InitCVIRTE(0, argv, 0) == 0) return -1;  // Out of memory
    if ((panel2 = LoadPanel(0, "Stim_only2.uir", PANEL_2)) < 0) return -1;
    SetPanelAttribute(panel2, ATTR_TOP, 72);
    SetPanelAttribute(panel2, ATTR_LEFT, 1000);
    DisplayPanel(panel2);
    CreateTask();
    RunUserInterface();
    return 0;
}

// CoreTask
int CoreTask(void) {
    for (int j = 0; j < 1; j++) {
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttlstate, &spcw, 0);
        Sleep(5);
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttloff, &spcw, 0);
        Sleep(5);
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttlstate, &spcw, 0);
        Sleep(90);
        DAQmxWriteDigitalLines(Pulsos_Stim, 1, 1, 10.0, DAQmx_Val_GroupByChannel, ttloff, &spcw, 0);
        Sleep(ISIbetw - 100);
    }
    return 0;
}

// GetRand Optimized
int GetRand(int min, int max) {
    static int seeded = 0;
    if (!seeded) {
        srand(time(NULL));
        seeded = 1;
    }
    return rand() % (max - min + 1) + min;
}

// Decimal to Binary Optimized with Direct Lookup
int* dec2bin(int c) {
    static int elbin[8];
    for (int i = 7; i >= 0; i--) {
        elbin[i] = (c & (1 << i)) ? 1 : 0;
    }
    return elbin;
}

int CreateTask(void) {
    statusPS = DAQmxCreateTask("Pulsos_Stim", &Pulsos_Stim);
    DAQmxCreateDOChan(Pulsos_Stim, "Dev1/port1/line0:7", "", DAQmx_Val_ChanPerLine);
    return statusPS;
}
*/