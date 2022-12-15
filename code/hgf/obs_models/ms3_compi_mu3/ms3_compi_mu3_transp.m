function [pvec, pstruct] = ms3_compi_mu3_transp(r, ptrans)
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

pvec    = NaN(1,length(ptrans));
pstruct = struct;
%function that transforms observation parameters to their native space from the space they are estimated in

pvec(1)     = sgm(ptrans(1),1);       % ze1
pstruct.ze1 = pvec(1);

return;