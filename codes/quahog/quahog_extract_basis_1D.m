function [n_ele,IEN] = quahog_extract_basis_1D(p,U)

n_ele = length(unique(U))-1;
IEN = zeros(p+1,n_ele);
iel = 0;
for iu = 1:length(U)-1
    if U(iu)~=U(iu+1)
        iel = iel + 1;
        IEN(:,iel) = linspace(iu-p,iu,p+1);
    end
end

end % function