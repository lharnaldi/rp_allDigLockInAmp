library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_lut is
	port(
		sine_o       : out   std_logic_vector(15 downto 0);       --Output sine_o
		theta          : in    std_logic_vector(9 downto 0);        --Input theta
		clk_i: in std_logic
   );
end sine_lut;


architecture rtl of sine_lut is

begin

 --process(theta)  --Combinatorial Logic Look Up Table
process(clk_i)
	variable theta_tmp: integer range 0 to 255;              --Lower bits of theta (counting up or counting down)
	variable theta_hlp: integer range 0 to 511;              --Helper for reversing lower bits of counting direction for theta
	variable sine_tmp: integer range 0 to 2047;              --Temporary Holder for output (two's compliment)
	variable tmp_sine_o: std_logic_vector(15 downto 0);    --Temporary Holder for output conversion
	variable var_sine_o: std_logic_vector(15 downto 0);    --Temporary Holder for two's compliment negation
	begin
	if (clk_i'event and clk_i='1') then
  	if (theta(8 downto 0) = conv_std_logic_vector(256,9)) then   --At 90 degrees and 270 degrees
    	sine_tmp := 1023;
    else
    	if(theta(8) = '1') then                                 --If counting down should begin reverse counting order
      	theta_hlp := 256 - conv_integer('0' & theta(7 downto 0));
      	theta_tmp := theta_hlp;
			else                                                    --Continue counting up by default
				theta_tmp := conv_integer(theta(7 downto 0));
			end if;
				case theta_tmp is                                       --Look Up Table (quarter wave)
		 			when 0 => sine_tmp := 0;
		 			when 1 => sine_tmp := 6;
		 			when 2 => sine_tmp := 13;
		 			when 3 => sine_tmp := 19;
		 			when 4 => sine_tmp := 25;
		 			when 5 => sine_tmp := 31;
		 			when 6 => sine_tmp := 38;
		 			when 7 => sine_tmp := 44;
		 			when 8 => sine_tmp := 50;
		 			when 9 => sine_tmp := 56;
		 			when 10 => sine_tmp := 63;
		 			when 11 => sine_tmp := 69;
		 			when 12 => sine_tmp := 75;
		 			when 13 => sine_tmp := 82;
		 			when 14 => sine_tmp := 88;
		 			when 15 => sine_tmp := 94;
		 			when 16 => sine_tmp := 100;
		 			when 17 => sine_tmp := 107;
		 			when 18 => sine_tmp := 113;
		 			when 19 => sine_tmp := 119;
		 			when 20 => sine_tmp := 125;
		 			when 21 => sine_tmp := 131;
		 			when 22 => sine_tmp := 138;
		 			when 23 => sine_tmp := 144;
		 			when 24 => sine_tmp := 150;
		 			when 25 => sine_tmp := 156;
		 			when 26 => sine_tmp := 163;
		 			when 27 => sine_tmp := 169;
		 			when 28 => sine_tmp := 175;
		 			when 29 => sine_tmp := 181;
		 			when 30 => sine_tmp := 187;
		 			when 31 => sine_tmp := 193;
		 			when 32 => sine_tmp := 200;
		 			when 33 => sine_tmp := 206;
		 			when 34 => sine_tmp := 212;
		 			when 35 => sine_tmp := 218;
		 			when 36 => sine_tmp := 224;
		 			when 37 => sine_tmp := 230;
		 			when 38 => sine_tmp := 236;
		 			when 39 => sine_tmp := 242;
		 			when 40 => sine_tmp := 249;
		 			when 41 => sine_tmp := 255;
		 			when 42 => sine_tmp := 261;
		 			when 43 => sine_tmp := 267;
		 			when 44 => sine_tmp := 273;
		 			when 45 => sine_tmp := 279;
		 			when 46 => sine_tmp := 285;
		 			when 47 => sine_tmp := 291;
		 			when 48 => sine_tmp := 297;
		 			when 49 => sine_tmp := 303;
		 			when 50 => sine_tmp := 309;
		 			when 51 => sine_tmp := 315;
		 			when 52 => sine_tmp := 321;
		 			when 53 => sine_tmp := 327;
		 			when 54 => sine_tmp := 333;
		 			when 55 => sine_tmp := 339;
		 			when 56 => sine_tmp := 345;
		 			when 57 => sine_tmp := 351;
		 			when 58 => sine_tmp := 356;
		 			when 59 => sine_tmp := 362;
		 			when 60 => sine_tmp := 368;
		 			when 61 => sine_tmp := 374;
		 			when 62 => sine_tmp := 380;
		 			when 63 => sine_tmp := 386;
		 			when 64 => sine_tmp := 391;
		 			when 65 => sine_tmp := 397;
		 			when 66 => sine_tmp := 403;
		 			when 67 => sine_tmp := 409;
		 			when 68 => sine_tmp := 415;
		 			when 69 => sine_tmp := 420;
		 			when 70 => sine_tmp := 426;
		 			when 71 => sine_tmp := 432;
		 			when 72 => sine_tmp := 437;
		 			when 73 => sine_tmp := 443;
		 			when 74 => sine_tmp := 449;
		 			when 75 => sine_tmp := 454;
		 			when 76 => sine_tmp := 460;
		 			when 77 => sine_tmp := 466;
		 			when 78 => sine_tmp := 471;
		 			when 79 => sine_tmp := 477;
		 			when 80 => sine_tmp := 482;
		 			when 81 => sine_tmp := 488;
		 			when 82 => sine_tmp := 493;
		 			when 83 => sine_tmp := 499;
		 			when 84 => sine_tmp := 504;
		 			when 85 => sine_tmp := 510;
		 			when 86 => sine_tmp := 515;
		 			when 87 => sine_tmp := 521;
		 			when 88 => sine_tmp := 526;
		 			when 89 => sine_tmp := 531;
		 			when 90 => sine_tmp := 537;
		 			when 91 => sine_tmp := 542;
		 			when 92 => sine_tmp := 547;
		 			when 93 => sine_tmp := 553;
		 			when 94 => sine_tmp := 558;
		 			when 95 => sine_tmp := 563;
		 			when 96 => sine_tmp := 568;
		 			when 97 => sine_tmp := 574;
		 			when 98 => sine_tmp := 579;
		 			when 99 => sine_tmp := 584;
		 			when 100 => sine_tmp := 589;
		 			when 101 => sine_tmp := 594;
		 			when 102 => sine_tmp := 599;
		 			when 103 => sine_tmp := 604;
		 			when 104 => sine_tmp := 609;
		 			when 105 => sine_tmp := 614;
		 			when 106 => sine_tmp := 619;
		 			when 107 => sine_tmp := 624;
		 			when 108 => sine_tmp := 629;
		 			when 109 => sine_tmp := 634;
		 			when 110 => sine_tmp := 639;
		 			when 111 => sine_tmp := 644;
		 			when 112 => sine_tmp := 649;
		 			when 113 => sine_tmp := 654;
		 			when 114 => sine_tmp := 659;
		 			when 115 => sine_tmp := 663;
		 			when 116 => sine_tmp := 668;
		 			when 117 => sine_tmp := 673;
		 			when 118 => sine_tmp := 678;
		 			when 119 => sine_tmp := 682;
		 			when 120 => sine_tmp := 687;
		 			when 121 => sine_tmp := 692;
		 			when 122 => sine_tmp := 696;
		 			when 123 => sine_tmp := 701;
		 			when 124 => sine_tmp := 705;
		 			when 125 => sine_tmp := 710;
		 			when 126 => sine_tmp := 714;
		 			when 127 => sine_tmp := 719;
		 			when 128 => sine_tmp := 723;
		 			when 129 => sine_tmp := 728;
		 			when 130 => sine_tmp := 732;
		 			when 131 => sine_tmp := 737;
		 			when 132 => sine_tmp := 741;
		 			when 133 => sine_tmp := 745;
		 			when 134 => sine_tmp := 750;
		 			when 135 => sine_tmp := 754;
		 			when 136 => sine_tmp := 758;
		 			when 137 => sine_tmp := 762;
		 			when 138 => sine_tmp := 766;
		 			when 139 => sine_tmp := 771;
		 			when 140 => sine_tmp := 775;
		 			when 141 => sine_tmp := 779;
		 			when 142 => sine_tmp := 783;
		 			when 143 => sine_tmp := 787;
		 			when 144 => sine_tmp := 791;
		 			when 145 => sine_tmp := 795;
		 			when 146 => sine_tmp := 799;
		 			when 147 => sine_tmp := 803;
		 			when 148 => sine_tmp := 806;
		 			when 149 => sine_tmp := 810;
		 			when 150 => sine_tmp := 814;
		 			when 151 => sine_tmp := 818;
		 			when 152 => sine_tmp := 822;
		 			when 153 => sine_tmp := 825;
		 			when 154 => sine_tmp := 829;
		 			when 155 => sine_tmp := 833;
		 			when 156 => sine_tmp := 836;
		 			when 157 => sine_tmp := 840;
		 			when 158 => sine_tmp := 844;
		 			when 159 => sine_tmp := 847;
		 			when 160 => sine_tmp := 851;
		 			when 161 => sine_tmp := 854;
		 			when 162 => sine_tmp := 858;
		 			when 163 => sine_tmp := 861;
		 			when 164 => sine_tmp := 864;
		 			when 165 => sine_tmp := 868;
		 			when 166 => sine_tmp := 871;
		 			when 167 => sine_tmp := 874;
		 			when 168 => sine_tmp := 877;
		 			when 169 => sine_tmp := 881;
		 			when 170 => sine_tmp := 884;
		 			when 171 => sine_tmp := 887;
		 			when 172 => sine_tmp := 890;
		 			when 173 => sine_tmp := 893;
		 			when 174 => sine_tmp := 896;
		 			when 175 => sine_tmp := 899;
		 			when 176 => sine_tmp := 902;
		 			when 177 => sine_tmp := 905;
		 			when 178 => sine_tmp := 908;
		 			when 179 => sine_tmp := 911;
		 			when 180 => sine_tmp := 914;
		 			when 181 => sine_tmp := 917;
		 			when 182 => sine_tmp := 919;
		 			when 183 => sine_tmp := 922;
		 			when 184 => sine_tmp := 925;
		 			when 185 => sine_tmp := 927;
		 			when 186 => sine_tmp := 930;
		 			when 187 => sine_tmp := 933;
		 			when 188 => sine_tmp := 935;
		 			when 189 => sine_tmp := 938;
		 			when 190 => sine_tmp := 940;
		 			when 191 => sine_tmp := 943;
		 			when 192 => sine_tmp := 945;
		 			when 193 => sine_tmp := 948;
		 			when 194 => sine_tmp := 950;
		 			when 195 => sine_tmp := 952;
		 			when 196 => sine_tmp := 954;
		 			when 197 => sine_tmp := 957;
		 			when 198 => sine_tmp := 959;
		 			when 199 => sine_tmp := 961;
		 			when 200 => sine_tmp := 963;
		 			when 201 => sine_tmp := 965;
		 			when 202 => sine_tmp := 967;
		 			when 203 => sine_tmp := 969;
		 			when 204 => sine_tmp := 971;
		 			when 205 => sine_tmp := 973;
		 			when 206 => sine_tmp := 975;
		 			when 207 => sine_tmp := 977;
		 			when 208 => sine_tmp := 979;
		 			when 209 => sine_tmp := 981;
		 			when 210 => sine_tmp := 983;
		 			when 211 => sine_tmp := 984;
		 			when 212 => sine_tmp := 986;
		 			when 213 => sine_tmp := 988;
		 			when 214 => sine_tmp := 989;
		 			when 215 => sine_tmp := 991;
		 			when 216 => sine_tmp := 992;
		 			when 217 => sine_tmp := 994;
		 			when 218 => sine_tmp := 995;
		 			when 219 => sine_tmp := 997;
		 			when 220 => sine_tmp := 998;
		 			when 221 => sine_tmp := 999;
		 			when 222 => sine_tmp := 1001;
		 			when 223 => sine_tmp := 1002;
		 			when 224 => sine_tmp := 1003;
		 			when 225 => sine_tmp := 1005;
		 			when 226 => sine_tmp := 1006;
		 			when 227 => sine_tmp := 1007;
		 			when 228 => sine_tmp := 1008;
		 			when 229 => sine_tmp := 1009;
		 			when 230 => sine_tmp := 1010;
		 			when 231 => sine_tmp := 1011;
		 			when 232 => sine_tmp := 1012;
		 			when 233 => sine_tmp := 1013;
		 			when 234 => sine_tmp := 1014;
		 			when 235 => sine_tmp := 1015;
		 			when 236 => sine_tmp := 1015;
		 			when 237 => sine_tmp := 1016;
		 			when 238 => sine_tmp := 1017;
		 			when 239 => sine_tmp := 1017;
		 			when 240 => sine_tmp := 1018;
		 			when 241 => sine_tmp := 1019;
		 			when 242 => sine_tmp := 1019;
		 			when 243 => sine_tmp := 1020;
		 			when 244 => sine_tmp := 1020;
		 			when 245 => sine_tmp := 1021;
		 			when 246 => sine_tmp := 1021;
		 			when 247 => sine_tmp := 1021;
		 			when 248 => sine_tmp := 1022;
		 			when 249 => sine_tmp := 1022;
		 			when 250 => sine_tmp := 1022;
		 			when 251 => sine_tmp := 1023;
		 			when 252 => sine_tmp := 1023;
		 			when 253 => sine_tmp := 1023;
		 			when 254 => sine_tmp := 1023;
		 			when 255 => sine_tmp := 1023;
				end case;
			end if;

			tmp_sine_o := conv_std_logic_vector(sine_tmp,16);

			if (theta > conv_std_logic_vector(512,10)) then               --Any theta between 180 and 360 degrees should be negative
				for i in tmp_sine_o'range loop
        	var_sine_o(i) := not tmp_sine_o(i);
    		end loop;
				sine_o <= var_sine_o + '1';
			else                                                        --Any theta between 0 and 180 degrees should be positive
    		sine_o <= tmp_sine_o;
			end if;
		end if;
	end process;
end rtl;
