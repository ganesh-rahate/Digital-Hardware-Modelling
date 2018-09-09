-- Author: Varun Nagpal
-- Net Id: vxn180010
-- VLSI Design Homework 1
-- 3rd Sept, 2018
--
-- Design: Testbench for the Generic Nth order (L = N+1 taps) Transposed Direct-form FIR-filter

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use work.fir_filter_shared_package.all;

entity Testbench is
end Testbench;

architecture test of testbench is
	-- clock and asynchronous reset
	signal clk 			: std_logic := '1';
	signal rst 			: std_logic := '0';

	-- Handshaking interface as source
	signal valid_x_out	: std_logic := 'X';
	signal ready_x_in	: std_logic;
	signal valid_h_out	: std_logic := 'X';
	signal ready_h_in	: std_logic;
	
	-- Handshaking interface as sink
	signal valid_in		: std_logic;
	signal ready_out	: std_logic := 'X';

	--  Signals for Input samples & coefficients to filter and reading Output samples of filter
	signal x_data_out	: signed(X_BIT_SIZE-1 downto 0) := (others => '0');
	signal h_data_out	: signed(H_BIT_SIZE-1 downto 0) := (others => '0');
	signal y_data_in	: signed(Y_BIT_SIZE-1 downto 0);	
begin

	-- Create an instance of the FIR filter
	DUT: entity work.fir_generic_transposed_filter(fir_rtl_arch) port map (	clk 		=> clk, 
																			rst 		=> rst,
																			valid_x_in	=> valid_x_out,
																			ready_x_out	=> ready_x_in,
																			valid_h_in	=> valid_h_out,
																			ready_h_out => ready_h_in,
																			valid_out 	=> valid_in,
																			ready_in 	=> ready_out,
																			x_data_in 	=> x_data_out,
																			h_data_in   => h_data_out,
																			y_data_out  => y_data_in	);
	-- Clock generation
	clk_gen: process
	begin
		clk <= '1';
		wait for CLK_HIGH_TIME;
		clk <= '0';
		wait for CLK_LOW_TIME;
	end process clk_gen;

	-- Reset generation
	rst <= 	'0', 
			'1' after 1 * CLK_CYCLE_TIME, 
			'0' after 2 * CLK_CYCLE_TIME;

	valid_h_out <= 	'X', 
					'1' after 2 * CLK_CYCLE_TIME, 
					'X' after 7	* CLK_CYCLE_TIME;

	h_data_out 	<= 	( others => 'X' ), 
					( 0 => '1', others => '0' )	after 2 * CLK_CYCLE_TIME,
					( others => 'X' ) 			after 7 * CLK_CYCLE_TIME;


	valid_x_out <= 	'X',
					'1' after 7 * CLK_CYCLE_TIME;

	x_data_out 	<= 	( others => 'X' ),
					( 0 => '1', others => '0' )	after 7 * CLK_CYCLE_TIME,
					( others => '1' ) 			after 15 * CLK_CYCLE_TIME;

	print_messages: process begin
		report  "ready_h = " & to_string( ready_h_in ) &
				" | valid_h = " & to_string( valid_h_out ) &
				" | h_data = " & to_string( to_integer( signed( h_data_out ) ) ) &
				" | ready_x = " & to_string( ready_x_in ) &
				" | valid_x = " & to_string( valid_x_out ) &
				" | x_data = " & to_string( to_integer( signed( x_data_out ) ) ) &
				" | ready_y = " & to_string( ready_out ) &
				" | valid_y = " & to_string( valid_in ) &
				" | y_data = " & to_string( to_integer( signed( y_data_in ) ) );
		wait for CLK_CYCLE_TIME;
	end process print_messages;

	stop_sim: process begin
		wait for 24*CLK_CYCLE_TIME;
		std.env.stop;
	end process stop_sim;
end architecture test;
