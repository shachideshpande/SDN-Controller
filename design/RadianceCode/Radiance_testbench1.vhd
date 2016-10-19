--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:38:10 04/06/2016
-- Design Name:   
-- Module Name:   /home/neeladri/Documents/sampleSRAM/SAL_test.vhd
-- Project Name:  sampleSRAM
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SAL
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.my_package.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SAL_test IS
END SAL_test;
 
ARCHITECTURE behavior OF SAL_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SAL
    PORT(
         A : IN  vector_vector_bool;
         en_in : IN  std_logic;
			traffic_en : IN  std_logic;
         traffic_matrix : IN  many_one_nodes;
         NextHop : OUT  vector_vector_int;
			real_time_status : out vertica;
			real_time_T_Table : out vertica_T;
			latency : out  integer:=0;
         jitter : out  integer:=0;
         total_drop : out  integer;
			latency_status: out delivery_status:=((others=> (others=>0)));
			jitter_status: out delivery_status:=((others=> (others=>0)));
			clk : in STD_LOGIC;
         rst : in STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal A : vector_vector_bool := (others=> (others=>'0')) ;
   signal en_in : std_logic := '0';
   signal traffic_en : std_logic := '0';
   signal traffic_matrix :  many_one_nodes := ((others=> (others=> (others=> (others=>'0')))));
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal NextHop : vector_vector_int := ((others=> (others=> (others=>'0'))));
   signal real_time_status : vertica;
	signal real_time_T_Table : vertica_T;
   signal latency : integer:=0;
   signal jitter : integer:=0;
   signal total_drop :integer:=0;
   signal latency_status : delivery_status:=((others=> (others=>0)));
   signal jitter_status : delivery_status:=((others=> (others=>0)));

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SAL PORT MAP (
          A => A,
          en_in => en_in,
          traffic_en => traffic_en,
          traffic_matrix => traffic_matrix,
          NextHop => NextHop,
          real_time_status => real_time_status,
          real_time_T_Table => real_time_T_Table,
          latency => latency,
          jitter => jitter,
          total_drop => total_drop,
          latency_status => latency_status,
          jitter_status => jitter_status,
          clk => clk,
          rst => rst
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;
		
--------------------------------- 0th clock cycle
		rst <= '0';
		en_in <= '1';
		A <= (	"00000000",--0
					"10100100",--1
					"00101010",--2
					"00010100",--3
					"01111000",--4
					"00010110",--5
					"00010000",--6
					"00000010"--7
				);
		wait for clk_period*1;
		en_in <= '0';
		wait for clk_period*3;
		-- sending trafic module at 4th clock cycle	
		traffic_en <= '1';
		traffic_matrix <= (
					(("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000001","0000000001","0000000000","0000000001","0000000000","0000000000","0000000001"),
					("0000000000","0000000001","0000000000","0000000001","0000000000","0000000001","0000000001","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000001","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0111111111","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000001","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000001","0000000000","0000000000","0000000001","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000111","0000000000","0100001001","0000000000","0000000000","0000000000"))
					,
					(("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000001","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000011","0000001111","0000000000"))

				);
		wait for clk_period*1; -- 5th clock cycle
		traffic_en <= '0';
		
		-- since all packets are delivered in above traffic before complition of 20 clock cycles
		-- 		hence no purpose of changing adjacancy matrix till 200 clock cycle
		
------------------------------------------------------------------------------
	
		wait for clk_period*195;
	--- 200th clock cycle
		en_in <= '1';
		A <= (	"00000000",
					"00000100",
					"00001000",
					"00010000",
					"00100000",
					"01000000",
					"10000000",
					"00000000"
				);
		wait for clk_period*1;
		en_in <= '0';
		wait for clk_period*3; -- 204th clock cycle
		
		-- sending trafic module at 204th clock cycle	
		traffic_en <= '1';
		traffic_matrix <= (
					(("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","1111111111"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000100000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"))
					,
					(("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"),
					("0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000","0000000000"))
				);
		wait for clk_period*1; -- 205th clock cycle
		traffic_en <= '0';
		
		-- changing Adjacancy Matrix, new next hop
		wait for clk_period*1; 
		-- 206th clock cycle
		-- few older links are broken and new links are formed
		-- message delivery is done according to new connectivity
		
		en_in <= '1';
		A <= (	"00000000",
					"01000000",
					"00000000",
					"00010000",
					"00100000",
					"01000000",
					"10000000",
					"00000000"
				);
		wait for clk_period*1;
		en_in <= '0';
		wait for clk_period*3; 
		
		-- 210th clock cycle
		wait for clk_period*190;
------------------------------------------------------------------------------------------------		
      -- new traffic matrix
		
		
		wait;
   end process;

END;
