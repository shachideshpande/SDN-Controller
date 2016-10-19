--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package my_package is

	constant N_width		: integer := 3;
	constant N		: integer := 8;
	constant node_memory : integer := 10;
	constant mid : integer := 8;--memory binary width allocated to messsage ID's
	constant k_max : integer := 2 ;--total types of application process in priority order
	
	type vector_int is array (0 to N-1) of STD_LOGIC_VECTOR(N_width -1 DOWNTO 0);
	type vector_vector_int is array (0 to N-1) of vector_int;
	type vector_vector_bool is array (0 to N-1) of STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	--type node_status is array (NATURAL range <> ) of integer;
	type node_status is array (0 to N-1) of integer;
	type delivery_status is array (0 to N-1) of node_status;
	
	type one_node is array (0 to N-1) of STD_LOGIC_VECTOR(node_memory-1 DOWNTO 0);
	-- all messages this node can give to multiple other nodes
	type any_one_nodes is array (0 to N-1) of one_node;
	type many_one_nodes is array (0 to k_max-1) of any_one_nodes;
	-- the complete traffic matrix
	
type verticaTemp is array (0 to N-1) of std_logic_vector(node_memory-1 downto 0);
type t_table_position is array (0 to N-1) of std_logic_vector(N-1 downto 0);
--this will be used to check whether a position is occupied or not
--the binary bit 0 means empty and 1 means occupied

type T_rec is--record style to be maintained in the T-table; for packet forwarding
	record
	  nxt : std_logic_vector(N_width-1 downto 0);--the decided nxt hop node
	  cur : std_logic_vector(N_width-1 downto 0);--the current node
     idN : std_logic_vector(mid-1 downto 0);--id of the packet
	  idx : integer;--memory index location on the original node of this packet
	end record;
type horizon_T is array (0 to N-1) of T_rec;-- clearly over estimating every node to be connected to every other node
type vertica_T is array (0 to N-1) of horizon_T;
--this creates an 2D-array of T_rec for our T-table

type rec is--record style of the actual packet in Real Time Status
	record
     src : std_logic_vector(N_width-1 downto 0);--the source node of the packet
     dst : std_logic_vector(N_width-1 downto 0);--the destination node of the packet
	  cur : std_logic_vector(N_width-1 downto 0);--the current node of the packet
     idN : std_logic_vector(mid-1 downto 0);--the ID of the packet
	  k : integer;--the application priority number of the message
  end record;
type horizon is array (0 to node_memory-1) of rec; 
type vertica is array (0 to N-1) of horizon;
--this creates a 2D array of rec for our Real Time Status

	
-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

end my_package;

package body my_package is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end my_package;
