----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:10:06 03/19/2016 
-- Design Name: 
-- Module Name:    algo - Behavioral 
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
-- Naming Conventions: DIRECTED GRAPH


--type vector_int is array (0 to N-1) of STD_LOGIC_VECTOR(N_width -1 DOWNTO 0);
--type vector_vector_int is array (0 to N-1) of vector_int;
--type vector_vector_bool is array (0 to N-1) of STD_LOGIC_VECTOR(N-1 DOWNTO 0);

-- A(i)(j) is true iff there is edge from node i to node j
-- 		A_i(0) means from i to node 0
--			A_1 <= "11110000"; 7th bit is 1

-- en_in true iff input is currently being given
-- en_out true iff output is legitimate

-- run_BFS can be avoided by using en_out; still it is *used for readability
------------------------------------------------------------------------------------
-- Flow of program

-- en = 1 : in this clock cycle read input : same output as previous -- 1st clock
-- in next clock cycle run BFS : en_out = 0 -- 2nd clock
-- from next clock cycle : en_out = 1 and output is NH wrto 1st clock

------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity algo is
	generic (
		N_width : integer := 3;
		N : integer := 8
	);
	Port (
		reset : in STD_LOGIC;
		clk : in STD_LOGIC;
		A : in vector_vector_bool;
		en_in : in STD_LOGIC;
		en_out : out STD_LOGIC;
		NH_out : out vector_vector_int
	);
end algo;

architecture Behavioral of algo is


shared variable E : vector_vector_int; -- Edges as Adjacency list
shared variable NH : vector_vector_int; -- Next_Hop Matrix

shared variable q : vector_int; -- BFS queue
shared variable visited : STD_LOGIC_VECTOR(0 to N-1); -- isVisited(i) is true iff ith node is visited during BFS
-- signal color : vector_int; -- color of node i
-- no need for color, map; NH value can be used as color itself

shared variable N_width_zeros : STD_LOGIC_VECTOR( N_width -1 DOWNTO 0) := (others=>'0');

-- k index storing
shared variable k : integer;

shared variable m : STD_LOGIC_VECTOR(N_width -1 DOWNTO 0);

signal run_BFS : STD_LOGIC; -- true iff run algo in next clock cycle
-- signal k_start : integer; -- start index in queue
-- 	not required
shared variable k_end : integer; -- end index in queue


begin

	process(reset,clk)
	begin
		if reset = '1' then --1
			-- initialize E,NH and q to -1 (node 0)
				for i in 0 to N-1 loop -- loop-1
					for j in 0 to N-1 loop -- loop-2
						E(i)(j) := N_width_zeros;
						NH(i)(j) := N_width_zeros;
						NH_out(i)(j) <= N_width_zeros;
					end loop; -- loop-2
					q(i) := N_width_zeros;
					visited(i) := '0';
				end loop; -- loop-1
			
			
			-- setting outputs as 0
				en_out <= '0';
				
			-- setting local signals as 0
				k := 0;
				m := N_width_zeros;
				
				run_BFS <= '0';
				k_end := 0;
			
			
		else--1
			
			if en_in = '1' then--2 read A within this clock cycle
				
				-------- start of reading E
				
				for p in 0 to N-1 loop
					for r in 0 to N-1 loop
						E(p)(r) := N_width_zeros;
					end loop;
				end loop;
				
				m := N_width_zeros + 1;
				k := 0;
						
				for i in 1 to N-1 loop
				
					for j in 1 to N-1 loop -- loop-1  start from 1; as node 0 represents -1			
					
					-------- storing in E

						if (A(i)(j) = '1') then--11
							E(i)(k) := m;
							k := k + 1;
						end if;--11
					
					-------- end of storing in E
					
					m := m + 1;
					
					end loop; -- loop-1
				
					m := N_width_zeros + 1;
					k := 0;
				
				end loop;
	
				
			---------------- end of reading E
			
			
			---------------- initialize NH, q, visited to 0
			
				for i in 0 to N-1 loop -- loop-1
					for j in 0 to N-1 loop -- loop-2
						NH(i)(j) := N_width_zeros;
					end loop; -- loop-2
					q(i) := N_width_zeros;
					visited(i) := '0';
				end loop; -- loop-1
				
			---------------- end of NH, q, visited initialisation
			run_BFS <= '1';
			en_out <= '0';			
			
			
			else--2 run BFS or show output
			
				if run_BFS = '1' then--3 run BFS
				
					---------------- starting BFS			
					
					for i in 1 to N-1 loop -- loop-1 : BFS over all nodes
						
						-- emptying q, visited, NH
							for j in 0 to N-1 loop -- loop-2
									NH(i)(j) := N_width_zeros;
								q(j) := N_width_zeros;
								visited(j) := '0';
							end loop; -- loop-2
						
						-- base step in BFS
							
							q(0) := std_logic_vector(to_unsigned(i,N_width));
							k_end := 1;
							visited(i) := '1';
							NH(i)(i) := std_logic_vector(to_unsigned(i,N_width));
							
							for j in 0 to N-1 loop -- loop-3 for all neighbours of node i
								
								if not ( E(i)(j) = N_width_zeros ) then --21
									NH(i)(to_integer(unsigned(E(i)(j)))) := E(i)(j);
									q(k_end) := E(i)(j);
									k_end := k_end + 1;
									visited(to_integer(unsigned(E(i)(j)))) := '1';
								end if; --21
								
							end loop; -- loop-3
							
						-- end of base step in BFS
						
						------ start of loop step in BFS
						
							for j in 0 to N-1 loop -- loop-4
							
								if not ( q(j) = N_width_zeros ) then -- 22
									
									for r in 0 to N-1 loop -- loop-5 for all neighbours of q(j)
										
										if not ( E(to_integer(unsigned(q(j))))(r) = N_width_zeros ) then -- 31
											if visited( to_integer(unsigned( E(to_integer(unsigned(q(j))))(r) )) ) = '0' then --32
												q(k_end) := E(to_integer(unsigned(q(j))))(r);
												k_end := k_end + 1;
												visited( to_integer(unsigned( E(to_integer(unsigned(q(j))))(r) )) ) := '1';
												NH(i)( to_integer(unsigned( E(to_integer(unsigned(q(j))))(r) )) ) := NH(i)(to_integer(unsigned(q(j))));
											end if; --32
											
										end if; -- 31
										
									end loop; -- loop-6
								
								end if; -- 22
								
							end loop; -- loop-4
						
						------ end of loop step in BFS
													
					end loop; -- loop-1
										
					---------------- ending BFS
						
					en_out <= '1';
					run_BFS <= '0';
					
				else --3 show output
				
					en_out <= '1';-- temparory line to avoid empty else
					NH_out <= NH;
				
				end if;--3
			
			end if;--2
		
		end if;--1
		
	end process;

end Behavioral;

