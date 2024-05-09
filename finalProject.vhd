library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity finalProject is
PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
		dac_LRCK : OUT STD_LOGIC;
		btPlay:IN STD_logic;
		btSave:IN std_logic;
		SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of eight 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
		dac_SCLK : OUT STD_LOGIC;
		dac_SDIN : OUT STD_LOGIC;
		octaveData:IN std_logic_vector(3 downto 0);
		noteData:IN std_logic_vector(3 downto 0)
	);
end finalProject;

architecture Behavioral of finalProject is
SIGNAL pitch : unsigned(13 downto 0);
SIGNAL wail_speed : UNSIGNED (7 DOWNTO 0) := to_unsigned (8, 8); -- sets wailing speed
SIGNAL octaveSig : std_logic_vector (3 DOWNTO 0);
SIGNAL noteSig : std_logic_vector (3 DOWNTO 0);
SIGNAL btSaveSig: STD_logic;
SIGNAL btPlaySig: STD_logic;
SIGNAL tcount : unsigned (20 DOWNTO 0) := (OTHERS => '0'); -- timing counter
SIGNAL data_L, data_R : SIGNED (15 DOWNTO 0); -- 16-bit signed audio data
SIGNAL dac_load_L, dac_load_R : STD_LOGIC; -- timing pulses to load DAC shift reg.
SIGNAL slo_clk, sclk, audio_CLK : STD_LOGIC;
TYPE state IS (ENTER_PITCH1, SAVE_PITCH1, relplaypitch5,relplaypitch2,relplaypitch3,relplaypitch4,PLAY_PITCH1, PLAY_PITCH2, PLAY_PITCH3, PLAY_PITCH4,ENTER_PITCH2, SAVE_PITCH2, ENTER_PITCH3, SAVE_PITCH3, ENTER_PITCH4, SAVE_PITCH4); -- state machine states
SIGNAL pr_state, nx_state : state := ENTER_PITCH1; -- present and next states
SIGNAL pitchHolder0 : unsigned (13 downto 0) := to_unsigned(0,14);
SIGNAL pitchHolder1 : unsigned (13 downto 0) := to_unsigned(0,14);
SIGNAL pitchHolder2 : unsigned (13 downto 0):= to_unsigned(0,14);
SIGNAL pitchHolder3 : unsigned (13 downto 0):= to_unsigned(0,14);
SIGNAL pitchCounter : unsigned (31 downto 0);
SIGNAL stateNUM : std_logic_vector(3 downto 0);
SIGNAL pitchIN : unsigned(13 downto 0);
SIGNAL sm_clk : std_logic;
SIGNAL recordonlyonce:std_logic;
SIGNAL cnt : unsigned(20 DOWNTO 0);
SIGNAL pitchCounterFlag: unsigned(13 downto 0);
Signal pitchIN2 : unsigned (13 downto 0) := to_unsigned(0,14);
Signal pitchIN3 : unsigned (13 downto 0) := to_unsigned(0,14);
Signal pitchIN4 : unsigned (13 downto 0) := to_unsigned(0,14);
Signal pitchIN5 : unsigned (13 downto 0) := to_unsigned(0,14);

COMPONENT tone IS
	PORT (
		clk : IN STD_LOGIC;
		pitch : IN UNSIGNED (13 DOWNTO 0);
		data : OUT SIGNED (15 DOWNTO 0)
	);
END COMPONENT;
COMPONENT leddec16 IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
COMPONENT dac_if IS
	PORT (
		SCLK : IN STD_LOGIC;
		L_start : IN STD_LOGIC;
		R_start : IN STD_LOGIC;
		L_data : IN signed (15 DOWNTO 0);
		R_data : IN signed (15 DOWNTO 0);
		SDATA : OUT STD_LOGIC
	);
END COMPONENT;


begin
tim_pr : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_50MHz);
		IF (tcount(9 DOWNTO 0) >= X"00F") AND (tcount(9 DOWNTO 0) < X"02E") THEN
			dac_load_L <= '1';
		ELSE
			dac_load_L <= '0';
		END IF;
		IF (tcount(9 DOWNTO 0) >= X"20F") AND (tcount(9 DOWNTO 0) < X"22E") THEN
			dac_load_R <= '1';
		ELSE dac_load_R <= '0';
		END IF;
		tcount <= tcount + 1;
	END PROCESS;
	octaveSIg<=octaveData;
	noteSig<=noteData;
pitch_sel : PROCESS 
	BEGIN
		IF octaveSig="0000" and noteSig="0000" THEN
			pitch <= to_unsigned (22, 14);
		ELSIF octaveSig="0000" and noteSig="0001" THEN
			pitch <= to_unsigned (23, 14);
		ELSIF octaveSig="0000" and noteSig="0010" THEN
			pitch <= to_unsigned (25, 14);
		ELSIF octaveSig="0000" and noteSig="0011" THEN
			pitch <= to_unsigned (26, 14);
		ELSIF octaveSig="0000" and noteSig="0100" THEN
			pitch <= to_unsigned (28, 14);
		ELSIF octaveSig="0000" and noteSig="0101" THEN
			pitch <= to_unsigned (29, 14);
		ELSIF octaveSig="0000" and noteSig="0110" THEN
			pitch <= to_unsigned (29, 14);
		ELSIF octaveSig="0000" and noteSig="0111" THEN
			pitch <= to_unsigned (31, 14);
		ELSIF octaveSig="0000" and noteSig="1000" THEN
			pitch <= to_unsigned (33, 14);
		ELSIF octaveSig="0000" and noteSig="1001" THEN
			pitch <= to_unsigned (35, 14);
		ELSIF octaveSig="0000" and noteSig="1010" THEN
			pitch <= to_unsigned (37, 14);
		ELSIF octaveSig="0000" and noteSig="1011" THEN
			pitch <= to_unsigned (39, 14);
		ELSIF octaveSig="0000" and noteSig="1100" THEN
			pitch <= to_unsigned (41, 14);
		ELSIF octaveSig="0000" and noteSig="1101" THEN
			pitch <= to_unsigned (41, 14);
		ELSIF octaveSig="0000" and noteSig="1110" THEN
			pitch <= to_unsigned (41, 14);
		ELSIF octaveSig="0000" and noteSig="1111" THEN
			pitch <= to_unsigned (41, 14);
		ELSIF octaveSig="0001" and noteSig="0000" THEN
			pitch <= to_unsigned (44, 14);
		ELSIF octaveSig="0001" and noteSig="0001" THEN
			pitch <= to_unsigned (46, 14);
		ELSIF octaveSig="0001" and noteSig="0010" THEN
			pitch <= to_unsigned (49, 14);
		ELSIF octaveSig="0001" and noteSig="0011" THEN
			pitch <= to_unsigned (52, 14);
		ELSIF octaveSig="0001" and noteSig="0100" THEN
			pitch <= to_unsigned (55, 14);
		ELSIF octaveSig="0001" and noteSig="0101" THEN
			pitch <= to_unsigned (59, 14);
		ELSIF octaveSig="0001" and noteSig="0110" THEN
			pitch <= to_unsigned (62, 14);
		ELSIF octaveSig="0001" and noteSig="0111" THEN
			pitch <= to_unsigned (66, 14);
		ELSIF octaveSig="0001" and noteSig="1000" THEN
			pitch <= to_unsigned (70, 14);
		ELSIF octaveSig="0001" and noteSig="1001" THEN
			pitch <= to_unsigned (74, 14);
		ELSIF octaveSig="0001" and noteSig="1010" THEN
			pitch <= to_unsigned (78, 14);
		ELSIF octaveSig="0001" and noteSig="1011" THEN
			pitch <= to_unsigned (83, 14);
		ELSIF octaveSig="0001" and noteSig="1100" THEN
			pitch <= to_unsigned (83, 14);
		ELSIF octaveSig="0001" and noteSig="1101" THEN
			pitch <= to_unsigned (83, 14);
		ELSIF octaveSig="0001" and noteSig="1110" THEN
			pitch <= to_unsigned (83, 14);
		ELSIF octaveSig="0001" and noteSig="1111" THEN
			pitch <= to_unsigned (83, 14);
		ELSIF octaveSig="0010" and noteSig="0000" THEN
			pitch <= to_unsigned (88, 14);
		ELSIF octaveSig="0010" and noteSig="0001" THEN
			pitch <= to_unsigned (93, 14);
		ELSIF octaveSig="0010" and noteSig="0010" THEN
			pitch <= to_unsigned (99, 14);
		ELSIF octaveSig="0010" and noteSig="0011" THEN
			pitch <= to_unsigned (104, 14);
		ELSIF octaveSig="0010" and noteSig="0100" THEN
			pitch <= to_unsigned (111, 14);
		ELSIF octaveSig="0010" and noteSig="0101" THEN
			pitch <= to_unsigned (117, 14);
		ELSIF octaveSig="0010" and noteSig="0110" THEN
			pitch <= to_unsigned (124, 14);
		ELSIF octaveSig="0010" and noteSig="0111" THEN
			pitch <= to_unsigned (132, 14);
		ELSIF octaveSig="0010" and noteSig="1000" THEN
			pitch <= to_unsigned (139, 14);
		ELSIF octaveSig="0010" and noteSig="1001" THEN
			pitch <= to_unsigned (148, 14);
		ELSIF octaveSig="0010" and noteSig="1010" THEN
			pitch <= to_unsigned (156, 14);
		ELSIF octaveSig="0010" and noteSig="1011" THEN
			pitch <= to_unsigned (166, 14);
		ELSIF octaveSig="0010" and noteSig="1100" THEN
			pitch <= to_unsigned (166, 14);
		ELSIF octaveSig="0010" and noteSig="1101" THEN
			pitch <= to_unsigned (166, 14);
		ELSIF octaveSig="0010" and noteSig="1110" THEN
			pitch <= to_unsigned (166, 14);
		ELSIF octaveSig="0010" and noteSig="1111" THEN
			pitch <= to_unsigned (166, 14);
		ELSIF octaveSig="0011" and noteSig="0000" THEN
			pitch <= to_unsigned (176, 14);
		ELSIF octaveSig="0011" and noteSig="0001" THEN
			pitch <= to_unsigned (186, 14);
		ELSIF octaveSig="0011" and noteSig="0010" THEN
			pitch <= to_unsigned (197, 14);
		ELSIF octaveSig="0011" and noteSig="0011" THEN
			pitch <= to_unsigned (209, 14);
		ELSIF octaveSig="0011" and noteSig="0100" THEN
			pitch <= to_unsigned (221, 14);
		ELSIF octaveSig="0011" and noteSig="0101" THEN
			pitch <= to_unsigned (234, 14);
		ELSIF octaveSig="0011" and noteSig="0110" THEN
			pitch <= to_unsigned (248, 14);
		ELSIF octaveSig="0011" and noteSig="0111" THEN
			pitch <= to_unsigned (263, 14);
		ELSIF octaveSig="0011" and noteSig="1000" THEN
			pitch <= to_unsigned (279, 14);
		ELSIF octaveSig="0011" and noteSig="1001" THEN
			pitch <= to_unsigned (295, 14);
		ELSIF octaveSig="0011" and noteSig="1010" THEN
			pitch <= to_unsigned (313, 14);
		ELSIF octaveSig="0011" and noteSig="1011" THEN
			pitch <= to_unsigned (331, 14);
		ELSIF octaveSig="0011" and noteSig="1100" THEN
			pitch <= to_unsigned (331, 14);
		ELSIF octaveSig="0011" and noteSig="1101" THEN
			pitch <= to_unsigned (331, 14);
		ELSIF octaveSig="0011" and noteSig="1110" THEN
			pitch <= to_unsigned (331, 14);
		ELSIF octaveSig="0011" and noteSig="1111" THEN
			pitch <= to_unsigned (331, 14);
		ELSIF octaveSig="0100" and noteSig="0000" THEN
			pitch <= to_unsigned (351, 14);
		ELSIF octaveSig="0100" and noteSig="0001" THEN
			pitch <= to_unsigned (372, 14);
		ELSIF octaveSig="0100" and noteSig="0010" THEN
			pitch <= to_unsigned (394, 14);
		ELSIF octaveSig="0100" and noteSig="0011" THEN
			pitch <= to_unsigned (417, 14);
		ELSIF octaveSig="0100" and noteSig="0100" THEN
			pitch <= to_unsigned (442, 14);
		ELSIF octaveSig="0100" and noteSig="0101" THEN
			pitch <= to_unsigned (469, 14);
		ELSIF octaveSig="0100" and noteSig="0110" THEN
			pitch <= to_unsigned (497, 14);
		ELSIF octaveSig="0100" and noteSig="0111" THEN
			pitch <= to_unsigned (526, 14);
		ELSIF octaveSig="0100" and noteSig="1000" THEN
			pitch <= to_unsigned (557, 14);
		ELSIF octaveSig="0100" and noteSig="1001" THEN
			pitch <= to_unsigned (591, 14);
		ELSIF octaveSig="0100" and noteSig="1010" THEN
			pitch <= to_unsigned (626, 14);
		ELSIF octaveSig="0100" and noteSig="1011" THEN
			pitch <= to_unsigned (663, 14);
		ELSIF octaveSig="0100" and noteSig="1100" THEN
			pitch <= to_unsigned (663, 14);
		ELSIF octaveSig="0100" and noteSig="1101" THEN
			pitch <= to_unsigned (663, 14);
		ELSIF octaveSig="0100" and noteSig="1110" THEN
			pitch <= to_unsigned (663, 14);
		ELSIF octaveSig="0100" and noteSig="1111" THEN
			pitch <= to_unsigned (663, 14);
		ELSIF octaveSig="0101" and noteSig="0000" THEN
			pitch <= to_unsigned (702, 14);
		ELSIF octaveSig="0101" and noteSig="0001" THEN
			pitch <= to_unsigned (744, 14);
		ELSIF octaveSig="0101" and noteSig="0010" THEN
			pitch <= to_unsigned (788, 14);
		ELSIF octaveSig="0101" and noteSig="0011" THEN
			pitch <= to_unsigned (835, 14);
		ELSIF octaveSig="0101" and noteSig="0100" THEN
			pitch <= to_unsigned (885, 14);
		ELSIF octaveSig="0101" and noteSig="0101" THEN
			pitch <= to_unsigned (938, 14);
		ELSIF octaveSig="0101" and noteSig="0110" THEN
			pitch <= to_unsigned (993, 14);
		ELSIF octaveSig="0101" and noteSig="0111" THEN
			pitch <= to_unsigned (1052, 14);
		ELSIF octaveSig="0101" and noteSig="1000" THEN
			pitch <= to_unsigned (1115, 14);
		ELSIF octaveSig="0101" and noteSig="1001" THEN
			pitch <= to_unsigned (1181, 14);
		ELSIF octaveSig="0101" and noteSig="1010" THEN
			pitch <= to_unsigned (1251, 14);
		ELSIF octaveSig="0101" and noteSig="1011" THEN
			pitch <= to_unsigned (1325, 14);
		ELSIF octaveSig="0101" and noteSig="1100" THEN
			pitch <= to_unsigned (1325, 14);
		ELSIF octaveSig="0101" and noteSig="1101" THEN
			pitch <= to_unsigned (1325, 14);
		ELSIF octaveSig="0101" and noteSig="1110" THEN
			pitch <= to_unsigned (1325, 14);
		ELSIF octaveSig="0101" and noteSig="1111" THEN
			pitch <= to_unsigned (1325, 14);
		ELSIF octaveSig="0110" and noteSig="0000" THEN
			pitch <= to_unsigned (1405, 14);
		ELSIF octaveSig="0110" and noteSig="0001" THEN
			pitch <= to_unsigned (1487, 14);
		ELSIF octaveSig="0110" and noteSig="0010" THEN
			pitch <= to_unsigned (1577, 14);
		ELSIF octaveSig="0110" and noteSig="0011" THEN
			pitch <= to_unsigned (1670, 14);
		ELSIF octaveSig="0110" and noteSig="0100" THEN
			pitch <= to_unsigned (1770, 14);
		ELSIF octaveSig="0110" and noteSig="0101" THEN
			pitch <= to_unsigned (1875, 14);
		ELSIF octaveSig="0110" and noteSig="0110" THEN
			pitch <= to_unsigned (1987, 14);
		ELSIF octaveSig="0110" and noteSig="0111" THEN
			pitch <= to_unsigned (2105, 14);
		ELSIF octaveSig="0110" and noteSig="1000" THEN
			pitch <= to_unsigned (2230, 14);
		ELSIF octaveSig="0110" and noteSig="1001" THEN
			pitch <= to_unsigned (2362, 14);
		ELSIF octaveSig="0110" and noteSig="1010" THEN
			pitch <= to_unsigned (2503, 14);
		ELSIF octaveSig="0110" and noteSig="1011" THEN
			pitch <= to_unsigned (2652, 14);
		ELSIF octaveSig="0110" and noteSig="1100" THEN
			pitch <= to_unsigned (2652, 14);
		ELSIF octaveSig="0110" and noteSig="1101" THEN
			pitch <= to_unsigned (2652, 14);
		ELSIF octaveSig="0110" and noteSig="1110" THEN
			pitch <= to_unsigned (2652, 14);
		ELSIF octaveSig="0110" and noteSig="1111" THEN
			pitch <= to_unsigned (2652, 14);
		ELSIF octaveSig="0111" and noteSig="0000" THEN
			pitch <= to_unsigned (2809, 14);
		ELSIF octaveSig="0111" and noteSig="0001" THEN
			pitch <= to_unsigned (2976, 14);
		ELSIF octaveSig="0111" and noteSig="0010" THEN
			pitch <= to_unsigned (3153, 14);
		ELSIF octaveSig="0111" and noteSig="0011" THEN
			pitch <= to_unsigned (3341, 14);
		ELSIF octaveSig="0111" and noteSig="0100" THEN
			pitch <= to_unsigned (3533, 14);
		ELSIF octaveSig="0111" and noteSig="0101" THEN
			pitch <= to_unsigned (3750, 14);
		ELSIF octaveSig="0111" and noteSig="0110" THEN
			pitch <= to_unsigned (3973, 14);
		ELSIF octaveSig="0111" and noteSig="0111" THEN
			pitch <= to_unsigned (4209, 14);
		ELSIF octaveSig="0111" and noteSig="1000" THEN
			pitch <= to_unsigned (4460, 14);
		ELSIF octaveSig="0111" and noteSig="1001" THEN
			pitch <= to_unsigned (4725, 14);
		ELSIF octaveSig="0111" and noteSig="1010" THEN
			pitch <= to_unsigned (5006, 14);
		ELSIF octaveSig="0111" and noteSig="1011" THEN
			pitch <= to_unsigned (5303, 14);
		ELSIF octaveSig="0111" and noteSig="1100" THEN
			pitch <= to_unsigned (5303, 14);
		ELSIF octaveSig="0111" and noteSig="1101" THEN
			pitch <= to_unsigned (5303, 14);
		ELSIF octaveSig="0111" and noteSig="1110" THEN
			pitch <= to_unsigned (5303, 14);
		ELSIF octaveSig="0111" and noteSig="1111" THEN
			pitch <= to_unsigned (5303, 14);
		ELSIF octaveSig="1000" and noteSig="0000" THEN
			pitch <= to_unsigned (5619, 14);
		ELSIF octaveSig="1000" and noteSig="0001" THEN
			pitch <= to_unsigned (5953, 14);
		ELSIF octaveSig="1000" and noteSig="0010" THEN
			pitch <= to_unsigned (6307, 14);
		ELSIF octaveSig="1000" and noteSig="0011" THEN
			pitch <= to_unsigned (6682, 14);
		ELSIF octaveSig="1000" and noteSig="0100" THEN
			pitch <= to_unsigned (7080, 14);
		ELSIF octaveSig="1000" and noteSig="0101" THEN
			pitch <= to_unsigned (7500, 14);
		ELSIF octaveSig="1000" and noteSig="0110" THEN
			pitch <= to_unsigned (7946, 14);
		ELSIF octaveSig="1000" and noteSig="0111" THEN
			pitch <= to_unsigned (8419, 14);
		ELSIF octaveSig="1000" and noteSig="1000" THEN
			pitch <= to_unsigned (8919, 14);
		ELSIF octaveSig="1000" and noteSig="1001" THEN
			pitch <= to_unsigned (9450, 14);
		ELSIF octaveSig="1000" and noteSig="1010" THEN
			pitch <= to_unsigned (10012, 14);
		ELSIF octaveSig="1000" and noteSig="1011" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF octaveSig="1000" and noteSig="1100" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF octaveSig="1000" and noteSig="1101" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF octaveSig="1000" and noteSig="1110" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF octaveSig="1000" and noteSig="1111" THEN
			pitch <= to_unsigned (10607, 14);	
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="0000" THEN
			pitch <= to_unsigned (5619, 14); 
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="0001" THEN
			pitch <= to_unsigned (5953, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="0010" THEN
			pitch <= to_unsigned (6307, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="0100" THEN
			pitch <= to_unsigned (7080, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="0101" THEN
			pitch <= to_unsigned (7500, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="0110" THEN
			pitch <= to_unsigned (7946, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="0111" THEN
			pitch <= to_unsigned (8419, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1000" THEN
			pitch <= to_unsigned (8919, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1001" THEN
			pitch <= to_unsigned (9450, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1010" THEN
			pitch <= to_unsigned (10012, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1011" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1100" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1101" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1110" THEN
			pitch <= to_unsigned (10607, 14);
		ELSIF (octaveSig="1000" or octaveSig="1001" or octaveSig="1010" or octaveSig="1011" or octaveSig="1100" or octaveSig="1101" or octaveSig="1110" or octaveSig="1111") and noteSig="1111" THEN
			pitch <= to_unsigned (10607, 14);
		ELSE
			pitch <= to_unsigned (10607, 14);
		END IF;
	END PROCESS;
	--ck_proc : PROCESS (clk_50MHz)
	--BEGIN
		--IF rising_edge(clk_50MHz) THEN -- on rising edge of clock
			--cnt <= cnt + 1; -- increment counter
		--END IF;
	--END PROCESS;
	sm_clk <= tcount(20);
	sm_ck_pr : PROCESS (sm_clk) -- state machine clock process
		BEGIN
			IF rising_edge (sm_clk) THEN -- on rising clock edge
				pr_state <= nx_state; -- update present state
			END IF;
		END PROCESS;
	sm_comb_pr : PROCESS  (btplay, btsave, pr_state)
		BEGIN
			CASE pr_state IS -- depending on present state...
				WHEN ENTER_PITCH1 => -- waiting for next digit in 1st operand entry
				    pitchIN<=pitch;
				    stateNUM<="0000";
				    
				    
					IF btPlay = '1' THEN
						nx_state <= play_pitch1;
					ELSIF btSave = '1' THEN
						nx_state <= SAVE_PITCH1;
					ELSE
					   nx_state <= ENTER_PITCH1;
					END IF;
				WHEN SAVE_PITCH1 => -- waiting for button to be released
				    pitchIN<=pitch;
				    stateNUM<="0001";
				    If btSave = '0' then
				        pitchIn2<=pitchIN2;
				        pitchHolder0<=pitchin2;
				        nx_state<=ENTER_PITCH2;
				    ELSE 
				        pitchIn2<=pitch;
				        nx_state<=SAVE_PITCH1;
				    END IF;
				WHEN ENTER_PITCH2 => -- waiting for next digit in 1st operand entry
				    pitchIN<=pitch;
				    stateNUM<="0010";
				    
					IF btPlay = '1' THEN
						nx_state <= play_pitch1;
					ELSIF btSave = '1' THEN
						nx_state <= SAVE_PITCH2;
					ELSE
					   nx_state <= ENTER_PITCH2;
					END IF;
			    WHEN SAVE_PITCH2 => -- waiting for button to be released
				    pitchIN<=pitch;
				    stateNUM<="0011";
				    If btSave = '0' then
				    pitchIn3<=pitchIN3;
				        pitchHolder1<=pitchin3;
				        nx_state<=ENTER_PITCH3;
				    ELSE 
				        pitchIn3<=pitch;
				        nx_state<=SAVE_PITCH2;
				    END IF;
				WHEN ENTER_PITCH3 => -- waiting for next digit in 1st operand entry
				    pitchIN<=pitch;
				    stateNUM<="0100";
				    
					IF btPlay = '1' THEN
						nx_state <= play_pitch1;
					ELSIF btSave = '1' THEN
						nx_state <= SAVE_PITCH3;
					ELSE
					   nx_state <= ENTER_PITCH3;
					END IF;
			    WHEN SAVE_PITCH3 => -- waiting for button to be released
				    pitchIN<=pitch;
				    stateNUM<="0101";
				    If btSave = '0' then
				    pitchIn4<=pitchIN4;
				        pitchHolder2<=pitchin4;
				        nx_state<=ENTER_PITCH4;
				    ELSE 
				        pitchIn4<=pitch;
				        nx_state<=SAVE_PITCH3;
				    END IF;
				WHEN ENTER_PITCH4 => -- waiting for next digit in 1st operand entry
				    pitchIN<=pitch;
				    stateNUM<="0111";
				    
					IF btPlay = '1' THEN
						nx_state <= play_pitch1;
					ELSIF btSave = '1' THEN
						nx_state <= SAVE_PITCH4;
					ELSE
					   nx_state <= ENTER_PITCH4;
					END IF;
				WHEN SAVE_PITCH4 => -- waiting for button to be released
				    pitchIN<=pitch;
				    stateNUM<="1000";
				    If btSave = '0' then
				    pitchIn5<=pitchIN5;
				        pitchHolder3<=pitchin5;
				        nx_state<=ENTER_PITCH1;
				    ELSE 
				        pitchIn5<=pitch;
				        nx_state<=SAVE_PITCH4;
				    END IF;
				--when relplaypitch1=>
				    --if btplay='0' Then
				       -- nx_state<=play_pitch1;
				    --else 
				       -- nx_state<=relplaypitch1;
				   -- end if;
				WHEN PLAY_PITCH1 => 
				stateNUM<="1001";
				    if btplay = '1' then
				        pitchIN<=pitchHolder0;
				        nx_state<=relplaypitch2;
				    ELSE
				        nx_state<=play_pitch1;
				    END IF;
				when relplaypitch2=>
				    if btplay='0' Then
				        nx_state<=play_pitch2;
				    else 
				        nx_state<=relplaypitch2;
				        pitchIN<=pitchHolder0;
				    end if;
				WHEN PLAY_PITCH2 => 
				stateNUM<="1010";
				    if btplay = '1' then
				        pitchIN<=pitchHolder1;
				        nx_state<=relplaypitch3;
				    ELSE
				        nx_state<=play_pitch2;
				    END IF;
				when relplaypitch3=>
				    if btplay='0' Then
				        nx_state<=play_pitch3;
				    else 
				        nx_state<=relplaypitch3;
				        pitchIN<=pitchHolder1;
				    end if;
				WHEN PLAY_PITCH3 => 
				stateNUM<="1011";
				    if btplay = '1' then
				        pitchIN<=pitchHolder2;
				        nx_state<=relplaypitch4;
				    ELSE
				        nx_state<=play_pitch3;
				    END IF;
				when relplaypitch4=>
				    if btplay='0' Then
				        nx_state<=play_pitch4;
				    else 
				        nx_state<=relplaypitch4;
				        pitchIN<=pitchHolder2;
				    end if;
				WHEN PLAY_PITCH4 => 
				stateNUM<="1100";
				    if btplay = '1' then
				        pitchIN<=pitchHolder3;
				        nx_state<=relplaypitch5;
				    ELSE
				        nx_state<=play_pitch4;
				    END IF;
			    when relplaypitch5=>
				    if btplay='0' Then
				        nx_state<=enter_pitch1;
				    else 
				        nx_state<=relplaypitch5;
				        pitchIN<=pitchHolder3;
				    end if;
				END CASE;
		END PROCESS;
	
	dac_MCLK <= NOT tcount(1); -- DAC master clock (12.5 MHz)
	audio_CLK <= tcount(9); -- audio sampling rate (48.8 kHz)
	dac_LRCK <= audio_CLK; -- also sent to DAC as left/right clock
	sclk <= tcount(4); -- serial data clock (1.56 MHz)
	dac_SCLK <= sclk; -- also sent to DAC as SCLK
	dac : dac_if
	PORT MAP(
		SCLK => sclk, -- instantiate parallel to serial DAC interface
		L_start => dac_load_L, 
		R_start => dac_load_R, 
		L_data => data_L, 
		R_data => data_R, 
		SDATA => dac_SDIN 
		);
	tgen : tone
	PORT MAP(
		clk => audio_clk, -- instance a tone module
		pitch => pitchIN, -- use curr-pitch to modulate tone
		data => Data_L
		);
	led1 : leddec16
	PORT MAP(
		dig => "000", data => stateNUM, 
		anode => SEG7_anode, seg => SEG7_seg
		);
		Data_R <= Data_L;
end Behavioral;
