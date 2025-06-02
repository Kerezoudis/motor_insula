function [chan] = chans_for_figs(pt) 

% This script contains the channels in M1 (precentral gyrus) that are 
%   somatotopitally tuned for hand, tongue or foot, as well as 
%   other important channels in various nodes of the motor network, 
%   particularly RMA, dorsal premotor or postcentral gyrus. 
%
% Panos Kerezoudis, CaMP lab, 2024.

switch pt
    
    case 'BRB' 
        chan.m1hand   = 34;
        chan.m1tongue = 79; 
        chan.m1foot   = NaN;
        chan.hins     = NaN;
        chan.tins     = 61;
        chan.fins     = NaN;
        chan.cmins    = NaN;

    case 'CCS' 
        chan.m1hand   = 110;
        chan.m1tongue = 120; 
        chan.m1foot   = NaN;
        chan.hins     = 99;
        chan.tins     = 102;
        chan.fins     = NaN;
        chan.cmins    = NaN;

    case 'CSJ' 
        chan.m1hand   = 126;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.hins     = 121;
        chan.tins     = 107;
        chan.fins     = NaN;
        chan.cmins    = [];
        
    case 'CZF' 
        chan.m1hand   = 137;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.prem     = 94;
        chan.hins     = NaN;
        chan.tins     = NaN;
        chan.fins     = NaN;
        chan.cmins    = 142;
   
    case 'DKS' 
        chan.m1hand   = 92;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.hins     = NaN;
        chan.tins     = [128 143];
        chan.fins     = 108;
        chan.cmins    = NaN;

    case 'EOW'
        chan.m1hand   = 71;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.hins     = 59;
        chan.tins     = 74;
        chan.fins     = NaN;
        chan.cmins    = NaN;

    case 'FKT'
        chan.m1hand   = NaN;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.hins     = NaN;
        chan.tins     = 106;
        chan.fins     = NaN;
        chan.cmins    = NaN;

    case 'FOD' 
        chan.m1hand   = 42;
        chan.m1tongue = 46; 
        chan.m1foot   = NaN;
        chan.hins     = 121;
        chan.tins     = 137;
        chan.fins     = NaN;
        chan.cmins    = 120;

    case 'JLL' 
        chan.m1hand   = NaN;
        chan.m1tongue = 120; 
        chan.m1foot   = NaN;
        chan.hins     = NaN;
        chan.tins     = 152;
        chan.fins     = NaN;
        chan.cmins    = NaN;

    case 'OSN'
        chan.m1hand   = NaN;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.hins     = 78;
        chan.tins     = [65; 156];
        chan.fins     = NaN;
        chan.cmins    = 78;

    case 'POC' 
        chan.m1hand   = 33;
        chan.m1tongue = 85; 
        chan.m1foot   = NaN;
        chan.postc    = 61;
        chan.hins     = 104;
        chan.tins     = 121;
        chan.fins     = NaN;
        chan.cmins    = 106;

    case 'ROR' 
        chan.m1hand   = 102;
        chan.m1tongue = 98; 
        chan.m1foot   = NaN;
        chan.rma      = 64;
        chan.hins     = 92;
        chan.tins     = 111;
        chan.fins     = NaN;
        chan.cmins    = 108;

    case 'TNJ' 
        chan.m1hand   = NaN;
        chan.m1tongue = 121; 
        chan.m1foot   = NaN;
        chan.hins     = 145;
        chan.tins     = 142;
        chan.fins     = 144;
        chan.cmins    = [];

    case 'TOS' 
        chan.m1hand   = 58;
        chan.m1tongue = 43; 
        chan.m1foot   = NaN;
        chan.hins     = NaN;
        chan.tins     = 65;
        chan.fins     = 62;
        chan.cmins    = 50;

    case 'TYL' 
        chan.m1hand   = 92;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.prem     = 140;
        chan.hins     = 112;
        chan.tins     = 109;
        chan.fins     = 107;
        chan.cmins    = NaN;

    case 'VLB' 
        chan.m1hand   = 125;
        chan.m1tongue = 122; 
        chan.m1foot   = NaN;
        chan.hins     = 133;
        chan.tins     = 119;
        chan.fins     = NaN;
        chan.cmins    = NaN;

    case 'WFR' 
        chan.m1hand   = NaN;
        chan.m1tongue = NaN; 
        chan.m1foot   = NaN;
        chan.rma      = 73;
        chan.hins     = NaN;
        chan.tins     = NaN;
        chan.fins     = NaN;
        chan.cmins    = 101;

end

end