# FinalProjectCPE487
Hello and Welcome to Joshua Marino and Zoe Casten's Final Project for CPE 487 Digital System Design at Stevens Institute of Technology. 
Below you will find information on what the project we created is about, what you need to run it, how to run it, how we created it, and how exactly it works.

I pledge my honor I have abided by the Steven's Honor System
-Joshua Marino and Zoe Casten

## Expected Behavior:
* Ability to control note and octave of sound coming out of a speaker
* Ability to save the current note and octave pitch by pressing the save button at least four times in four different signals
* Ability to play back all four of the saved signals consecutively while holding the play button
* Display the current state of the finite state machine using the anode display
![Play Pitch Part of Second FSM](https://github.com/JoshuaMarinoo/FinalProjectCPE487/blob/main/Play%20Pitch%20Part%20of%20Second%20FSM)
![Save Pitch Part of Second FSM](https://github.com/JoshuaMarinoo/FinalProjectCPE487/blob/main/Save%20Pitch%20Part%20of%20Second%20FSM)
  
## Attachments Needed:
* Pmod I2S Digital to Analog Converter
* Wired Speaker or Headphones


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

* [insert videoes of the board and code working]

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
  * Output that deal with what anode in the display we turn on
* SEG7_seg
  * Output that deals with what segments of the anode in the display we turn on
* Outputs to the digital to analog converter that allow it run in sync with the board, and allow it to convert the the data we want it to convert
  * DAC_MCLK
  * DAC_SDIN
  * DAC_SCLK
  * DAC_LRCK


## Modifications

* We used the code from the Siren lab, Lab 5, as our jumping-off point. We used source parts from dac_if.vhd, tone.vhd, and siren.vhd and we used the siren.xdc constraint file as well. We also additionally used code from the Hexcalc lab borrowing the FSM from its main code and signals and processes relating to it, leddec code file and the xdc file lines that mapped the anode and segment outputs to the respective pins of the board. 
* There are two versions of our project: one that plays all of the notes consecutively after saving, as a sort of song; and one that plays each note in order every time you hit play.
  *  The code included in this submission is the one that plays each note when you press the button
  *  The code that played all of the notes consecutively worked up to a point with there being a bug that we would not diagnose that would cause after a note had been played for the amount of time it needed to, the current note being played and the next note being played would then switch over and over and then it would play the next note. Far from optimable, we ended up submitting the button one as that actually worked
* We mainly modified the siren.vhd file as our main code. We expanded off of the original siren code by adding several different signals that handle pitches and saves. We also added in the FSM (finite state machine) that handles storing pitches and playing them.
* Process of Modifications
  * We first wanted to implement our code to work with saving and playing only one pitch and then expand the code from there
  * We took the DAC_if, tone files and use them both unchanged in our project code
  * The main modifications of our code occurs in the siren.vhd
    * We deleted the component initialization of the wail object, we delete the mapping of the wail object and we delete any signals that dealt with the wail object.
      * lo_tone
      * hi_tone
      * wail_speed
    * We added a component initialization of a tone object, we then add a mapping of that tone object, mapping the clk input of the tone to the audioclk signal already present in the siren file, mapping data input of the Data_L signal already present in the siren.vhd and leaving the pitch input empty for the time being as we are going to set it to a signal that we have yet to make
    * We then added two new input std logic vectors(3 downto 0) octaveData and noteData into the finalProject, then adding some pin mapping lines in the finalProject constraint file and mapping the four leftmost switches to the bits of octaveData and the four rightmost switches to the bits of noteData. We used these switches to as binary numbers to choose which octave and note we are going to be in
    * We then made two intermediate signals called octaveSig and noteSig and set them to the input values from octaveData and noteData to avoid any complications with using the input port for different things
    * We then made a process called pitch_sel which is going to see what is in octaveSig and noteSig, then using the values of octaveSig and noteSig chooses the pitch of the tone we are going to play is, to hold the pitch we made a new signal called pitch and then in the process itself we made a very long if else statement that checks the octaveSig and noteSig and sees whether it is a specific value, and set pitch to the specific pitch that corresponds with the note and octave data we are currently reading
      * There are only 12 notes and 9 octaves in total, but with four switches we are going to have 16 total options to choose from, so what we did was set the if else statement to have the same output for the last 7 octaves as long as the note remains the same, and have the same output for the last 5 notes as long as the octave remains the same
      * We chose the specific pitch for a specific octave and note combination by using a pitch frequency chart based on note and octave that is included in the related diagrams, images and videos part of the readme, we then assigned the specific pitch frequency to the pitch signal by using to_unsigned(x,14) where x is the frequency of the specific note in the specific octave we are in and we use 14 bits since the pitch in the tone code is 14 bits long unsigned
    * We then realized we needed to create an FSM to move through the different states of changing pitch, saving the pitch and then playing the pitch, so what we did was copy and paste a couple of signals and the FSM process from the hexcalc lab and started to cut away from it and add to it to make it work for what we wanted it to do
      * Copy and Pasting the type already created in hexcalc called state, deleting the current states that are in and replacing them with the states we are going to use called enter_pitch, save_pitch, and play_pitch
      * Copy and Pasting the signals nx_state and pr_state which are meant to hold the next state and the present state that is being used in the FSM, along with another separate signal sm_clk which is going to be the clock we use to switch between states, we then set the sm_clk to the 20th bit of tcount, tcount being a signal already in siren.vhd that in another process is being incremented by 1 every single rising edge of the 50Mhz clk
      * Copy and Pasting the sm_ck_pr process which is the clock process for the state machine and only keeping the lines
        * IF rising_edge (sm_clk) THEN -- on rising clock edge  pr_state <= nx_state; -- update present state
         * this makes it so on the rising edge of the sm_clk, so every time the 20 bit of tcount changes from 0 to 1 then we set the present state to the next state
      * Copy and Pasting the FSM process in hexcalc and deleting the first couple of signal setting lines and deleting most of the case statement and leaving only three possible cases which we will change to be our state of enter_pitch, save_pitch and play_pitch
        * The first case will be when pr_state is enter_pitch
          * In the first state we are going to be checking if the play button or the save button have been pressed by checking if their input ports are '1' if the save button input port is 1 then we set nx_state to save_pitch and if the play button input port is 1 then we set nx_state to play_pitch, if none of the two buttons are pressed then we will set nx_state to enter_pitch so that it will keep looping and stay in the enter_pitch untill one of the two buttons are pressed. In this state, we also want to choose the pitch being played through the speaker by changing the switches relating to the current note and current octave, but since we also later on want to set the pitch being played to a different pitch than what is being chosen by the switches we made an intermediate signal called pitchIn that is mapped to the pitch input of the tone component this will act as an intermediate signal whose value will change from either the pitch chosen by the switches or the pitch that we save in save_pitch. So in the first state the pitchIn signal will be set to the pitch signal that is chosen by the switches so that the operator may hear what pitch they choosing
          * In the second state, save_pitch, we are going to save the pitch signal currently generated by the switches however we need somewhere to store the information of th epitch signal so that it stays the same if the switches change, so we add another signal caled pitchHolder. When we are in the second state, we are going to check if the save button has been let go if it has then we will set pitchHolder to the pitch signal which holds the unsigned value created by the octave and data switches and then we will set nx_state to the enter_pitch state, if the button has not been let go then we set nx_state to save_pitch and keep looping in this state.
          * In the third and final state for the moment, play_pitch,  we are going to want to play the pitch that we saved beforehand on the speaker regardless of the switch position at the time we are in the third state, to do this we have the state check if the play button is still being held and if it is being held then we set pitchIN to pitchHolder, effectively playing the pitch that saved previously and setting the nx_state to play_pitch effectively looping in the state while we are pressing the button so that pitch we saved beforehand is always playing while we are pressing the button, if the play button is no longer being pressed then we will set the nx_state to enter_pitch
    * This code worked and was able to play the current pitch being selected by the switches, save the pitch, and then play it back, now the next thing we needed to accomplish was making this work for multiple pitches and including a display that was able to display using the anodes on the board itself what state in the FSM we currently were in
![First FSM](https://github.com/JoshuaMarinoo/FinalProjectCPE487/blob/main/One%20Pitch%20FSM)
      * The multiple pitches part of this proved to be the hardest hurdle of the project to overcome, as we had some initial problems with the way we originally saved the pitches.
        * When we originally tried to solve the problem of having multiple pitches be able to be saved and the same time and then played when the play button was pressed, we first tried to keep only three states and modify them to work with multiple pitches, to do this we needed to add a couple signals playCounter and pitchCounter which were signals whose whole point was to count how many times the play pitch button was pressed or the save pitch button was pressed, along with adding more pitchHolder signals under the names of pitchHolder0 through pitchHolder3. We then modified the save_pitch so that whenever it was pressed in the new save_pitch process we would then check what the current value of pitchCounter was and then set the pitchHolder corresponding to that value of pitchCounter to pitch and then increment pitchCounter 1, and when pitchCounter reached the value of 4 we would then reset pitchCounter to 0 and then set nx_state to save_pitch so that we can then rewrite the pitch at pitchHolder0 once we have saved more than four pitches
        * We did the same thing with the play_pitch where each time the play button was pressed we checked what the value of playCounter was and then set pitchIn to the pitchHolder value corresponding to that playCounter value, and when playCounter reached 4 we would then move back to the enter_pitch state by setting nx_state to enter_pitch and in enter_pitch we would set play_counter to 0 theoretically allowing the state to play all four pitches.
        * We saw problems in these, which we think was because of the clock, wherein one button press of either the play button or the save button the playcounter or pitchcounter would actually be incremented more than once, we tried to implement another signal called onlyincrementonce so that the state would do the same thing but only increment the pitchCounter and playCounter when the onlyincrementonce signal was 0, and the onlyincrementonce signal would then be set to one and only be set back to zero when either of the buttons was pressed again. This also did not work which we think was also caused by the clock.
        * We then moved on to the implementation that would actually work, we made the saving and playing, along with the entering of the pitches all individual states, so there would be 4 enter_pitch states, 4 save_pitch states and 4 play_pitch states all deal with one of the four pitchHolder signals we are using at that specific state. 
          * For each of the four enter_pitch states, enter_pitch1, enter_pitch2, enter_pitch3, and enter_pitch4, we would have the state check whether the play button or the save button was pressed, if the save button was pressed the nx_state would then be set to the save_pitch that corresponds to the number of enter_pitch it is in, so enter_pitch1 would set the nx_state to save_pitch1, enter_pitch2 to save_pitch2 and so on. Each of the enter_pitch states, if the play button was pressed would always move to play_pitch1 state and if nothing was pressed we would set nx_state to the current enter_pitch state we are in.
          * For each of the four save_pitch states, we will set the pitchHolder whose number is one minus the save_pitch number to the current pitch, and then when the save button is  let go we set the nx_state to the enter_pitch state that is one more than the current save_pitch state number so save_pitch1 will go to enter_pitch2 and save_pitch2 will go to enter_pitch3, and save_pitch4 will go to enter_pitch1 to repeat the cycle again when we save 4 pitches, this rewrites the pitches when we save more than four pitches.
            * This did not work fully correctly, one thing we noticed when implementing this was that if we saved two different pitches the first pitch would a mix of the two pitches being saved, what we had to do then was implement multiple intermediate signals, we named them PitchIN2 through PitchIN5, these signals would serve as an intermediate between the pitch signal we are getting from the switches and the pitchHolder signal we ultimately want that signal to be set too. So what we did was instead of just setting pitchHolder to pitch, what we did was when the save button was being held while we were in any of the save_pitch states we set pitchIN whose number is one more than the number of the save_pitch state we are in to pitch and then set nx_state to the save_pitch we are in, so when the button is held in save_pitch1 we will set pitchIN2 to pitch, in save_pitch2 we will set pitchIN3 to pitch and so on. Then when the save button is let go, we will set the pitchIN that corresponds to the save_pitch state we are in to itself so that any changes in pitch will not affect the value in the pitchIn signal we are using, we will then set the pitchHolder that corresponds to the save_pitch state we are in to pitchIN that corresponds to the save_pitch state we are in, thus keeping any signal contamination that we were seeing before out of the pitchHolder signals.
![Save Pitch Part of Second FSM](https://github.com/JoshuaMarinoo/FinalProjectCPE487/blob/main/Save%20Pitch%20Part%20of%20Second%20FSM)
          * For the actual playing of the pitches we saved we would need to separate the playing of each pitch into two different states, the play_pitch state and the relplaypitch state. The play_pitch state would deal with the initial press of the play button, where in the case of play_pitch1 if the button is pressed when we are in the state we would set pitchIN to the pitchHolder that corresponds to the current play_pitch state we are in, which for play_pitch1 would be pitchHolder0 and then sets the nx_state to relplaypitch2, and if the button is not pressed in the state we would just stay in play_pitch1. Then in relplaypitch2, we would then see if the button is continuing to be pressed, if it is still being pressed then we set pitchIN to the pitchHolder that corresponds to the current relplaypitch state we are in which for relplaypitch2 would be pitchHolder0 and then we stay in relplaypitch2, by setting the nx_state to the current relplaypitch state we are in or in thise case relplaypitch2. If the button is let go then we set nx_state to the next play_pitch state, which in the case of relplaypitch2 is play_pitch2. However in the case of relplaypitch5, the state after play_pitch4, we can not go to play_pitch5 so what we do instead is set the nx_state to enter_pitch if the button is let go so that we can rechoose pitches or restart the play cycle again.
![Play Pitch Part of Second FSM](https://github.com/JoshuaMarinoo/FinalProjectCPE487/blob/main/Play%20Pitch%20Part%20of%20Second%20FSM)
      * To implement the display showing which state in the FSM we are in at the moment, we needed to borrow a couple more things from the hexcalc lab. This being the leddec code file, along with the component initialization of the leddec object, and the mapping for a specific instance of the leddec object, new output port that deal with turning on the anode itself and segments of the anode to display values and lines from the xdc file that map pins in the ports to those ouputs.We then added the two new output ports SEG7_anode, SEG7_seg that will deal with sending output to the pins we assign them to, we then need to add in the constraint file the lines that match the output port bits to the pins relating to the anode and its segments. We then put the component initialization of the leddec object in the finalProject.vhd file, along with the mapping for one instance of the object. We then map dig, which select which display part to turn on to "000" so it only turns on the first digit of the display always, we map the output that deal with the anode and segments of the anode to the two new output ports we created and then we map the data input of the leddec instance to a new signal we are going to created called stateNUM which will be a four bit std_logic_vector, we then need to add a line in each of the states of the FSM assigning it a specific and indiviudal stateNum, this will then cause the anode display to show that state we are in with a hexadecimal representation of the stateNum of the state we are currently in.



	

	
