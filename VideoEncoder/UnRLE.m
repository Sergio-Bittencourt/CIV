function recon_block = reconstructBlock(matrix, ele_num, blockLength)

    if blockLength==8
    recon_matrix = [matrix, zeros(1, 64-ele_num)];
    
    
    % Reconstruct Matrix through simple zig zag.
    recon_block = [recon_matrix(1) recon_matrix(2) recon_matrix(6) recon_matrix(7) recon_matrix(15) recon_matrix(16) recon_matrix(28) recon_matrix(29);
                   recon_matrix(3) recon_matrix(5) recon_matrix(8) recon_matrix(14) recon_matrix(17) recon_matrix(27) recon_matrix(30) recon_matrix(43);
                   recon_matrix(4) recon_matrix(9) recon_matrix(13) recon_matrix(18) recon_matrix(26) recon_matrix(31) recon_matrix(42) recon_matrix(44);
                   recon_matrix(10) recon_matrix(12) recon_matrix(19) recon_matrix(25) recon_matrix(32) recon_matrix(41) recon_matrix(45) recon_matrix(54);
                   recon_matrix(11) recon_matrix(20) recon_matrix(24) recon_matrix(33) recon_matrix(40) recon_matrix(46) recon_matrix(53) recon_matrix(55);
                   recon_matrix(21) recon_matrix(23) recon_matrix(34) recon_matrix(39) recon_matrix(47) recon_matrix(52) recon_matrix(56) recon_matrix(61);
                   recon_matrix(22) recon_matrix(35) recon_matrix(38) recon_matrix(48) recon_matrix(51) recon_matrix(57) recon_matrix(60) recon_matrix(62);
                   recon_matrix(36) recon_matrix(37) recon_matrix(49) recon_matrix(50) recon_matrix(58) recon_matrix(59) recon_matrix(63) recon_matrix(64);];
       
    end
    
    if blockLength==4
      
      recon_matrix = [matrix, zeros(1, 16-ele_num)];
               
      recon_block = [recon_matrix(1) recon_matrix(2) recon_matrix(6) recon_matrix(7);
                    recon_matrix(3)  recon_matrix(5) recon_matrix(8) recon_matrix(13);
                    recon_matrix(4) recon_matrix(9) recon_matrix(12) recon_matrix(14);
                    recon_matrix(10) recon_matrix(11) recon_matrix(16) recon_matrix(15);];
       end
  
      if blockLength==16
                 
     r = [matrix, zeros(1, 256-ele_num)];
               
     recon_block = [r(1)    r(2)    r(6)     r(7)   r(15)   r(16)   r(28)    r(29)   r(45)   r(46)   r(66)   r(67)   r(91)  r(92)   r(120)  r(121);      
          r(3)    r(5)    r(8)     r(14)  r(17)   r(27)   r(30)    r(44)   r(47)   r(65)   r(68)   r(90)  r(93)   r(119)  r(122)  r(151);  
          r(4)    r(9)    r(13)    r(18)  r(26)   r(31)   r(43)    r(48)   r(64)   r(69)   r(89)   r(94)  r(118)  r(123)  r(150)  r(152);  
         r(10)    r(12)   r(19)    r(25)  r(32)   r(42)   r(49)    r(63)   r(70)   r(88)   r(95)   r(117) r(124)  r(149)  r(153)  r(178);
         r(11)    r(20)   r(24)    r(33)  r(41)   r(50)   r(62)    r(71)   r(87)   r(96)   r(116)  r(125) r(148)  r(154)  r(177)  r(179);
         r(21)    r(23)   r(34)    r(40)  r(51)   r(61)   r(72)    r(86)   r(97)   r(115)  r(126)  r(147) r(155)  r(176)  r(180)  r(201);
         r(22)    r(35)   r(39)    r(52)  r(60)   r(73)   r(85)    r(98)   r(114)  r(127)  r(146)  r(156) r(175)  r(181)  r(200)  r(202);
         r(36)    r(38)   r(53)    r(59)  r(74)   r(84)   r(99)    r(113)  r(128)  r(145)  r(157)  r(174) r(182)  r(199)  r(203)  r(220);  
         r(37)    r(54)   r(58)    r(75)  r(83)   r(100)  r(112)   r(129)  r(144)  r(158)  r(173)  r(183) r(198)  r(204)  r(219)  r(221);
         r(55)    r(57)   r(76)    r(82)  r(101)  r(111)  r(130)   r(143)  r(159)  r(172)  r(184)  r(197) r(205)  r(218)  r(222)  r(235);
         r(56)    r(77)   r(81)    r(102) r(110)  r(131)  r(142)   r(160)  r(171)  r(185)  r(196)  r(206) r(217)  r(223)  r(234)  r(236);
         r(78)    r(80)   r(103)   r(109) r(132)  r(141)  r(161)   r(170)  r(186)  r(195)  r(207)  r(216) r(224)  r(233)  r(237)  r(246);
         r(79)    r(104)  r(108)   r(133) r(140)  r(162)  r(169)   r(187)  r(194)  r(208)  r(215)  r(225) r(232)  r(238)  r(245)  r(247);
         r(105)   r(107)  r(134)   r(139) r(163)  r(168)  r(188)   r(193)  r(209)  r(214)  r(226)  r(231) r(239)  r(244)  r(248)  r(253);
         r(106)   r(135)  r(138)   r(164) r(167)  r(189) r(192)   r(210)  r(213)  r(227)  r(230)  r(240) r(243)  r(249)  r(252)  r(254);
         r(136)   r(137)  r(165)   r(166) r(190)  r(191)  r(211)   r(212)  r(228)  r(229)  r(241)  r(242) r(250)  r(251)  r(255)  r(256);];       
        
      end
    
end