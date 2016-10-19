----------------------------------------------------------------------------------
-- Company: Radiance
-- Engineer: Neeladrishekhar Kanjilal & Ashna Gaur
-- 
-- Create Date:    13:10:33 03/11/2016 
-- Design Name: 
-- Module Name:    TrafficModule - Behavioral 
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

-- traffic_matrix(k)(i)(j)(m) represents from node i to destination j and m'th message 
-- of priority k_max - k - 1

-------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TrafficModule is
	generic ( N : integer := 7 ;--current code is for max 7 nodes coded for node 0 is null
				 numN : integer := 8;--max number of nodes possible
				 N_wid : integer := 3;--max binary width for node. Here max is 20=>atleast 5bits
				 mid : integer := 8;--memory binary width allocated to messsage ID's
				 k_max : integer := 2 ;--total types of application process in priority order
				 mem_w : integer := 10--width of memory for each node
				);
    Port ( --n1TOn2K2 : in STD_LOGIC_VECTOR(mem_w-1 DOWNTO 0);--further if we have another priority application 
--           n2TOn1K2 : in STD_LOGIC_VECTOR(mem_w-1 DOWNTO 0);
			  traffic_en : in STD_LOGIC;--make from low to high for taking the traffic matrix
			  traffic_matrix : in many_one_nodes;
			  NH_out : in vector_vector_int;
--			  output : out STD_LOGIC_VECTOR(N_wid-1 DOWNTO 0);			  
				real_time_status : out vertica;
				real_time_T_Table : out vertica_T;
				real_time_dropped_p : out node_status;
				real_time_delivery_p : out delivery_status;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end TrafficModule;

architecture Behavioral of TrafficModule is

type horizonNH is array (0 to numN-1) of std_logic_vector(N_wid-1 downto 0);
type verticaNH is array (0 to numN-1) of horizonNH;
--this creates a 2D array of node numbers for our Next Hop Matrix

shared variable counter : std_logic_vector(mid-1 downto 0) := (others=>'0');
shared variable position : verticaTemp;--positioning for real time status
shared variable position_T : t_table_position;--positioning for T-table
shared variable next_node,curr_node : std_logic_vector(N_wid-1 downto 0);
shared variable temp_numN : std_logic_vector(mem_w-1 downto 0) := (others=>'0');--a node having no messages , all positions in a node are empty
shared variable temp_N : std_logic_vector(numN-1 downto 0) := (others=>'0');--a node having no decided next hop for T_table
shared variable empty_mid : std_logic_vector(mid-1 downto 0) := (others=>'0');--representing integer 0
shared variable null_node : std_logic_vector(N_wid-1 downto 0) := (others=>'0');--representing a null node
shared variable temp_rec : rec;
shared variable empty_rec : rec := (null_node,null_node,null_node,empty_mid,0);
shared variable empty_T_rec : T_rec := (null_node,null_node,empty_mid,0);
shared variable temp_bit : std_logic;
shared variable dropped_p : node_status;
shared variable delivery_p : delivery_status;

----signal I_real_time_dropped_p : node_status(numN-1 downto 0);
--signal real_time_dropped_p : node_status;
--signal real_time_delivery_p : delivery_status;

shared variable testing1 : vertica;--testing1 is our real time status
--signal NH : verticaNH;--The NH matrix for next hop
shared variable NH : vector_vector_int;
shared variable T_Table : vertica_T;--our T-table which has all messages that are gonna go in the current clock cycle

signal real_time_position : verticaTemp;
signal real_time_position_T : t_table_position;

begin

process (rst, clk, traffic_en)
begin
	if (rst = '1') then
		--output <= "000";
		for i in 0 to numN-1 loop
			position(i) := temp_numN;
			position_T(i) := temp_N;
--			dropped_p(i) := empty_mid;
			dropped_p(i) := 0;
			for j in 0 to numN-1 loop
				T_Table(i)(j) := empty_T_rec;
			end loop;
			for j in 0 to mem_w-1 loop
				testing1(i)(j) := empty_rec;
			end loop;
		end loop;
		for i in 0 to numN-1 loop
			delivery_p(i) := dropped_p;
		end loop;
		real_time_T_Table <= T_Table;
		real_time_position_T <= position_T;
		real_time_status <= testing1;
		real_time_position <= position;
		real_time_dropped_p <= dropped_p;
		real_time_delivery_p <= delivery_p;
		
	elsif rising_edge(clk) then
	
		NH := NH_out;--taking the NextHop matrix
		for i in 0 to numN-1 loop
--			dropped_p(i) := empty_mid;
			dropped_p(i) := 0;
		end loop;
		for i in 0 to numN-1 loop
			delivery_p(i) := dropped_p;--initiallizing to empty
		end loop;
		
	if traffic_en = '0' then
	
		for i in 0 to numN-1 loop--in every node
			for j in 0 to mem_w-1 loop--inside the memory
				if position(i)(j) = '1' then--if there is something in that position
					temp_rec := testing1(i)(j);--get the record of packet at that position
					next_node := NH(i)(to_integer(unsigned(temp_rec.dst)));--get the next hop for that packet from that node(i) to the destination stored in it
					
					if temp_rec.cur = null_node then
						position(i)(j) := '0';--empty that place
						testing1(i)(j) := empty_rec;
						dropped_p(i) := dropped_p(i) + 1;
						
					elsif temp_rec.dst = temp_rec.cur then--if already at destination
						position(i)(j) := '0';--empty that place
						testing1(i)(j) := empty_rec;
						delivery_p(to_integer(unsigned(temp_rec.src)))(i) := delivery_p(to_integer(unsigned(temp_rec.src)))(i) + 1;
						--//some code for sending to stats as Successful message
						
					elsif position_T(i)(to_integer(unsigned(next_node))) = '0' then--if T-table is empty for that next-hop node
					--This will get more condensed if we are also seeing different priority multiple applications
						
						position_T(i)(to_integer(unsigned(next_node))) := '1';--fill this place
						T_Table(i)(to_integer(unsigned(next_node))) := (next_node,temp_rec.cur,temp_rec.idN,j);
						-- T-Table generated
					elsif position_T(i)(to_integer(unsigned(next_node))) = '1' then
						-- for higher priority packets+9
						if testing1(i)(T_Table(i)(to_integer(unsigned(next_node))).idx).k < temp_rec.k then
							T_Table(i)(to_integer(unsigned(next_node))) := (next_node,temp_rec.cur,temp_rec.idN,j);
						end if;
						--temp_rec.k > 
					end if;
				end if;
			end loop;
		end loop;
		
		-- Switch Manager 
		for i in 0 to numN-1 loop--changing the real time status based on the T-table
			for j in 0 to numN-1 loop
				if position_T(i)(j) = '1' then
					next_node := T_Table(i)(j).nxt;
					temp_rec := testing1(i)(T_Table(i)(j).idx);--getting the packet from real time status
					temp_bit := '0';--to notify for packet dropping
					for p in 0 to mem_w-1 loop--finding an empty place inside the nexthops memory
						if position(to_integer(unsigned(next_node)))(p) = '0' then
							temp_bit := '1';--packet was not drop
							position(to_integer(unsigned(next_node)))(p) := '1';--shifting the packet record to the new node
							temp_rec.cur := next_node;
							testing1(to_integer(unsigned(next_node)))(p) := temp_rec;
							exit;--//break of the loop
						end if;
					end loop;
					position(i)(T_Table(i)(j).idx) := '0';
					testing1(i)(T_Table(i)(j).idx) := empty_rec;
					if temp_bit = '0' then--we found no place inside the next hop node
										
						dropped_p(i) := dropped_p(i) + 1;
						--//some code for sending to stats as dropped message
							
					end if;
				end if;
			end loop;
		end loop;
		
	elsif traffic_en = '1' then
	
		for i in 0 to numN-1 loop-- firstly apply the time to leave(TTL) for all the packets
			for j in 0 to mem_w-1 loop
				if position(i)(j) = '1' then
					position(i)(j) := '0';-- dropping all packets who fail to reach within TTL
					testing1(i)(j) := empty_rec;
					dropped_p(i) := dropped_p(i) + 1;
				end if;
			end loop;
		end loop;
	
	for kk in 0 to k_max-1 loop
		for i in 0 to numN-1 loop
			for j in 0 to numN-1 loop
				for mm in 0 to mem_w-1 loop--(i)(j) represents from node i to node j
					if traffic_matrix(kk)(i)(j)(mm) = '1' then
						counter := counter + 1;
						curr_node := std_logic_vector(to_unsigned(i, curr_node'length));
						next_node := std_logic_vector(to_unsigned(j, next_node'length));
						--actually here we just use the variable name "next_node" for destination node
						temp_rec := (curr_node,next_node,curr_node,counter,k_max-1-kk);
						temp_bit := '0';
						for k in 0 to mem_w-1 loop
							if(position(i)(k)='0') then
								position(i)(k):='1';
								testing1(i)(k):=temp_rec;
								
								--//some code for sending to stats as generated message id
								
								temp_bit := '1';
								exit;
							end if;
						end loop;
						if ( temp_bit = '0') then
							
							dropped_p(i) := dropped_p(i) + 1;
							--//some code for sending to stats as dropped message
								
						end if;
					end if;
				end loop;
			end loop;
		end loop;
	end loop;	
	end if;
	--getting all the data generated to the output signal being used
		
		real_time_T_Table <= T_Table;
		real_time_position_T <= position_T;
		for i in 0 to numN-1 loop--emptying the T-table
			position_T(i) := temp_N;
		end loop;
		real_time_status <= testing1;
		real_time_position <= position;
		real_time_dropped_p <= dropped_p;
		real_time_delivery_p <= delivery_p;
	end if;
end process;

end Behavioral;