------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date:    15:10:49 03/12/2016 
---- Design Name: 
---- Module Name:    overall_stats - Behavioral 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
--package my_pack1 is
-- type node_status is array (NATURAL range <>) of std_logic_vector(7 downto 0);
-- type delivery_status is array ( NATURAL range <>) of node_status(7 downto 0);
--end package;
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use work.my_pack1.all;
---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
--
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
----library UNISIM;
----use UNISIM.VComponents.all;
--
--entity overall_stats is
--    Port ( delivery : inout delivery_status(7 downto 0);
--           drop : inout  node_status(7 downto 0);
--			  clk : in std_logic;
--           latency : inout  integer;
--           jitter : inout  integer;
--           total_drop : inout  integer;
--			  latency_status: inout delivery_status( 7 downto 0);
--			  jitter_status:inout delivery_status( 7 downto 0)
--			  );
--end overall_stats;
--
--architecture Behavioral of overall_stats is
--type mat is array (0 to 7) of node_status(7 downto 0);
--signal count: integer :=0;
--signal total_delivery_count : integer :=0;
----signal total_latency : integer :=0;
--signal first_calc_total: integer :=0;
--signal drop_status,delivery_count,first_calc: mat:= ((others=> (others=>"00000000")));
--begin
--process(clk)
--	begin
--		if(clk'event and clk='1' and count=200) then
--			count<=0;
--		else 
--			count<=count+1;
--		end if;
--		if(clk'event and clk='1') then
--			for i in 0 to 7 loop
--				for j in 0 to 7 loop
--				if (not(delivery(i)(j) = "00000000")) then
--					delivery_count(i)(j)<=std_logic_vector(unsigned(delivery_count(i)(j))+unsigned(delivery(i)(j)));
--					latency_status(i)(j)<=(latency_status(i)(j)*delivery_count(i)(j)+count*delivery(i)(j))/(delivery_count(i)(j)+delivery(i)(j));
--					if(first_calc_total=0) then
--					jitter<=0;
--					else
--					jitter<=jitter_status(i)(j)+abs(latency_status(i)(j)-count)/16;
--					first_calc_total<=1;
--					end if;
--					if(first_calc(i)(j)=0) then
--					jitter_status(i)(j)<=0;
--					else
--					first_calc(i)(j)<=1;
--					jitter_status(i)(j)<=jitter_status(i)(j)+abs(latency_status(i)(j)-count)/16;
--					end if;
--					total_delivery_count<=total_delivery_count+delivery(i)(j);
--					latency<=(total_delivery_count*latency+count*delivery(i)(j))/(delivery_count(i)(j)+total_delivery_count);
--					
--				end if;
--				end loop;
--			
--			total_drop<=total_drop+drop(i);
--			end loop;
--		end if;
--	end process;
--
--end Behavioral;
--
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:49 03/12/2016 
-- Design Name: 
-- Module Name:    overall_stats - Behavioral 
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use work.my_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity overall_stats is
generic(
	N: integer :=8
);
    Port ( delivery : in delivery_status; -- number of packets delivered to destination j from source i at current clock cycle
           drop : in  node_status; -- number of packets dropped at each node at given clock cycle
			  clk : in std_logic;
           latency : out  integer; -- average end-to-end delay for all nodes
           jitter : out  integer; -- average jitter for all nodes
           total_drop : out  integer; -- total number of drops on all nodes upto this clock cycle
			  latency_status : out delivery_status; -- average end-to-end delay for each path (i,j)
			  jitter_status: out delivery_status; -- jitter for each path (i,j)
			  reset : in std_logic
			  );
end overall_stats;

architecture Behavioral of overall_stats is
type mat is array (0 to N-1) of node_status;
shared variable count: integer :=0;
shared variable total_delivery_count : integer :=0; -- total number of packet deliveries
shared variable temp_total_latency : integer :=0; -- total time taken for all packets to deliver, one at a time
shared variable first_calc_total: integer :=0; -- boolean for whether this is the 1st calculation of jitter
shared variable temp_drop: integer :=0; -- total number of drops till previous clock cycle
shared variable total_packet_num: integer :=0; -- total number of packets delivered until this clock tick
shared variable prev_count_total: integer :=0; -- count value at the previous clock cylce when delivery was made
shared variable prev_jitter: integer :=0; -- jitter calculated at previous clock cycle
-- following matrices have been used to maintain state while calculating all statistics
shared variable drop_status,delivery_count,prev_jitter_status,prev_count,first_calc,temp_latency_status: delivery_status:= ((others=> (others=>0)));
begin

process(clk)
	begin
		if(reset = '1') then
			latency <=0; -- average end-to-end delay for all nodes
         jitter <=0; -- average jitter for all nodes
			total_drop <=0; -- total number of drops on all nodes upto this clock cycle
		   latency_status <= ((others=> (others=>0))); -- average end-to-end delay for each path (i,j)
		   jitter_status <= ((others=> (others=>0)));-- jitter for each path (i,j)
		end if;
		if(clk'event and clk='1') then
			if(count=200) then
				count:=0;
			else 
				count:=count+1;
			end if;
		end if;

		if(clk'event and clk='1') then
			for i in 0 to N-1 loop
				for j in 0 to N-1 loop
				if (not(delivery(i)(j) = 0)) then
					prev_count_total:=count;					
					prev_count(i)(j):=count;
					first_calc(i)(j):=1;
					first_calc_total:=1;
					delivery_count(i)(j):=delivery_count(i)(j)+delivery(i)(j);
					total_packet_num:=total_packet_num+delivery(i)(j);
					temp_latency_status(i)(j):=(temp_latency_status(i)(j))+count*delivery(i)(j);
					latency_status(i)(j)<=temp_latency_status(i)(j)/(delivery_count(i)(j)+1);
					if(first_calc_total=0) then
						prev_jitter:=0;
					else
						prev_jitter:=prev_jitter+abs(prev_count_total-count)/16;
						
					end if;
					if(first_calc(i)(j)=0) then
						prev_jitter_status(i)(j):=0;
					else
						prev_jitter_status(i)(j):=prev_jitter_status(i)(j)+abs(prev_count(i)(j)-count)/16;
					end if;
					total_delivery_count:=total_delivery_count+delivery(i)(j);
					temp_total_latency:=temp_total_latency+count*delivery(i)(j);
					latency<=temp_total_latency/(total_packet_num+1);
					jitter<=prev_jitter;
					jitter_status(i)(j)<=prev_jitter_status(i)(j);
				end if;
			end loop;
			temp_drop:=temp_drop+drop(i);

			end loop;
			
		end if;
		total_drop<=temp_drop;
	end process;

end Behavioral;