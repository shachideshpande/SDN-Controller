----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:12:54 04/06/2016 
-- Design Name: 
-- Module Name:    SAL - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SAL is
Port (   A : IN  vector_vector_bool;
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
         rst : in STD_LOGIC);
end SAL;

architecture Behavioral of SAL is

signal NH_out : vector_vector_int;
signal en_out : std_logic;
signal drop : node_status;
signal delivery : delivery_status;

	COMPONENT algo
    PORT(
         reset : IN  std_logic;
         clk : IN  std_logic;
         A : IN  vector_vector_bool;
         en_in : IN  std_logic;
         en_out : OUT  std_logic;
         NH_out : OUT  vector_vector_int
        );
    END COMPONENT;
	
	COMPONENT overall_stats
     Port ( 
				delivery : in delivery_status:=((others=> (others=>0)));
           drop : in node_status;--:=(others=>"00000000");
			  clk : in std_logic;
           latency : out  integer:=0;
           jitter : out  integer:=0;
           total_drop : out  integer;--:="00000000";
			  latency_status: out delivery_status:=((others=> (others=>0)));
			  jitter_status: out delivery_status:=((others=> (others=>0)));
			  reset : in std_logic
			  );
    END COMPONENT;
	 
	 COMPONENT TrafficModule
    PORT(
         traffic_en : IN  std_logic;
         traffic_matrix : IN  many_one_nodes;
         NH_out : IN  vector_vector_int;		  
			real_time_status : out vertica;
			real_time_T_Table : out vertica_T;
			real_time_dropped_p : out node_status;
			real_time_delivery_p : out delivery_status;
         clk : IN  std_logic;
         rst : IN  std_logic
        );
    END COMPONENT;
	 
begin

Algorithm_Block :  algo PORT MAP (
          reset => rst,
          clk => clk,
          A => A,
          en_in => en_in,
          en_out => en_out,
          NH_out => NH_out
        );	
    
Traffic_Module : TrafficModule PORT MAP (
          traffic_en => traffic_en,
          traffic_matrix => traffic_matrix,
          NH_out => NH_out,		  
				real_time_status => real_time_status,
				real_time_T_Table => real_time_T_Table,
				real_time_dropped_p => drop,
				real_time_delivery_p => delivery,
          clk => clk,
          rst => rst
        );
		  
Statistics_Manager : overall_stats PORT MAP (
          delivery => delivery,
          drop => drop,
          clk => clk,
          latency => latency,
          jitter => jitter,
          total_drop => total_drop,
          latency_status => latency_status,
          jitter_status => jitter_status,
			 reset => rst 
        );
		  
process (rst,clk)
begin
	NextHop <= NH_out;
end process;

end Behavioral;

