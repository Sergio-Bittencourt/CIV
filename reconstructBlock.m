function recon_block = reconstructBlock(matrix, ele_num)
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