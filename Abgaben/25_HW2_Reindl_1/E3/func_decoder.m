function [ MSG ] = func_decoder( vT )
%
%
%
%
% Neumayer 2014

SYMB = 'abcdefghijklmnopqrstuvwxyz 0123456789.';
%SYMB(27) = ' ';
MSG = [];
for ii = 1:length(vT)
    [~,idx] = min( abs([1:size(SYMB,2)] - vT(ii)) );
    MSG = [MSG,SYMB(idx)]; 
end

end

