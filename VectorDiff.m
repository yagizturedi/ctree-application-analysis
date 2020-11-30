% This function returns the number of different items over number of total
% items on the vectors when two vector of same length are given to the
% function.

function Error=VectorDiff(X,Y)


if length(X)~=length(Y)
    
elseif isvector(X)&&isvector(Y)
    
    Diff=X-Y;
    
    Error=0;
    
    for i=1:length(X)
        if Diff(i)~=0
            Error=Error+1;
        end
    end
    
    Error=Error/length(X);
    
end
