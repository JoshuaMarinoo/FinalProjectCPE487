# FinalProjectCPE487
Hello and Welcome to Joshua Marino and Zoe Casten's Final Project for CPE 487 Digital System Design at Stevens Institute of Technology. 
Below you will find information on what the project we created is about, what you need to run it, how to run it, how we created it, and how exactly it works.

I pledge my honor I have abided by the Steven's Honor System

## Expected Behavior:
* Ability to control note and octave of sound coming out of a speaker
* Ability to save the current note and octave pitch by pressing the save button at least four times in four different signals
* Ability to play back all four of the saved signals consecutively while holding the play button
* Display the current state of the finite state machine using the anode display

  
## Attachments Needed:
* Pmod I2S Digital to Analog Converter
* Wired Speaker or Headphones

## Related Diagrams, Images and Videos:
* [insert photo of final two finite state machines here]
* [insert videoes of the board and code working]

## How to Use Code and Vivado Board:
1. Download the following files and put them into a Vivado Project as Sources and Constraints in respect to their file type
   * finalProject.vhd
   * leddec16.vhd
   * dac_if.vhd
   * tone.vhd
   * finalProject.xdc
  
2. Set Up the Board
   * Connect the Pmod I2S to the Board
   * Connect the Speaker to the Pmod I2S
   * Connect the Board to the Computer
   * Configure the Board for USB Power and USB Data Upload by adjusting the necessary jumpers

3. Run Synthesis
   
5. Run Implementation
   
7. Generate Bitstream
   
9. Send Bitstream to the Board
    
11. Check the constraint file downloaded to see which switches and buttons correspond to the note data, octave data, play button, and save button. (Edit input sources used if needed)
    
13. Change the pitch by changing the note and octave through their respective switches
    
15. Press the save button
    
17. Repeat steps eight through nine three more times, saving a total of four pitches
    
19. Press the play button and hear all four pitches played in a loop consecutively

## Inputs from and Outputs to Board:
### Inputs
* 50 MHz Clock
  * Gets a 50 Mhz Clock signal from the board and sends its values to the std_logic value of the input port of the Vivado Project
  * Used for multiple timing processes
  * Used for making sub clock signals where a counter increments a clock signal by one each rising edge of the 50 Mhz clock
* Play Button
  * Gets the value from the assigned button and sends that to the input port which uses std_logic in the Vivado Project
  * Controls whether the saved notes are played or not
* Save Button
  * Gets the value from the assigned button and sends that to the input port which uses std_logic in the Vivado Project
  * Controls whether the pitch associated with the current value of the octave and note switches is saved to one of the four pitch holder signals 
* Octave Switches
  *  Gets the values from the assigned switches and sends each switch data to its corresponding individual bit of the std_logic_vector of the input port in the Vivado Project
  *  Controls which octave the sound coming from the speaker is at 
* Note Switches
  * Gets the values from the assigned switches and sends each switch data to its corresponding individual bit of the std_logic_vector of the input port in the Vivado Project
  * Controls which note the sound coming from the speaker is at
### Outputs
* SEG7_anode
* SEG7_seg
* DAC_MCLK
* DAC_SDIN
* DAC_SCLK
* DAC_LRCK
* implement explanations

### Modifications









	

	* “Modifications” (15 points of the Submission category)
		* If building on an existing lab or expansive starter code of some kind, describe your “modifications” – the changes made to that starter code to improve the code, create entirely new functionalities, etc. Unless you were starting from one of the labs, please share any starter code used as well, including crediting the creator(s) of any code used. It is perfectly ok to start with a lab or other code you find as a baseline, but you will be judged on your contributions on top of that pre-existing code!
		* If you truly created your code/project from scratch, summarize that process here in place of the above.
	* Conclude with a summary of the process itself – who was responsible for what components (preferably also shown by each person contributing to the github repository!), the timeline of work completed, any difficulties encountered and how they were solved, etc. (10 points of the Submission category)
* And of course, the code itself separated into appropriate .vhd and .xdc files. (50 points of the Submission category; based on the code working, code complexity, quantity/quality of modifications, etc.)
* You are not really expected to be github experts – as long as one of you can confidently create the repository and help others add to it, that should be sufficient. If no group members fall under this criteria, discuss with me as soon as possible.
	* This is a group assignment, and for the most part you are graded as a group. I reserve the right to modify single student grades for extenuating circumstances, such as a clear lack of participation from a group member. You are allowed to rely on the expertise of your group members in certain aspects of the project, but you should all have at least a cursory understanding of all aspects of your project.
