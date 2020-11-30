% Yaðýz Türedi 

clear
clc
%% Reading The Table

[TableNum,TableStr,TableCell]=xlsread("FlightDelays.xls");

%% Reformatting The Data

Table=TableNum;


% date fix
TableStr(1,:)=[];
Table(:,6)=datenum(TableStr(:,6),'dd.mm.yy');

% carrier fix
for i=1:11
CarrierNum{i}=TableStr{i+8,14};
end

CC = cellstr(TableStr(:,2));

for i=1:length(Table)
    for j=1:length(CarrierNum)
        if sum(CC{i}==CarrierNum{j})==2
            Table(i,2)=j;
        end
    end            
end

% airport fix

AP=cellstr(TableStr(:,4));
AParr=cellstr(TableStr(:,8));

AirportNum=cellstr(unique(TableStr(:,4)));
AirportArrNum=cellstr(unique(TableStr(:,8)));

for i=1:length(Table)
    for j=1:length(AirportNum)
        if sum(AP{i}==AirportNum{j})==3
            Table(i,4)=j;
        end
    end
    for j=1:length(AirportArrNum)
        if sum(AParr{i}==AirportArrNum{j})==3
            Table(i,8)=j;
        end
    end
end

% plane fix

PL = cellstr(TableStr(:,12));
PlaneNum=unique(PL);

for i=1:length(Table)
    for j=1:length(PlaneNum)
        if sum(PL{i}==PlaneNum{j})==6
            Table(i,12)=j;
        end
    end
end

% label fix

label=cellstr(TableStr(:,13));
for i=1:length(Table)
    if length(label{i})==length('ontime')
        Table(i,13)=0;
    else
        Table(i,13)=1;
    end
end

%% Partitioning The Dataset

x=randperm(length(Table),round(length(Table)/5,0));
Validation=zeros(length(x),12);
ValDelay=zeros(length(x),1);
for i=1:length(x)
    Validation(i,[1:12])=Table(x(i),[1:12]);
    ValDelay(i)=Table(x(i),13);
end

Training=zeros(length(Table)-length(x),12);
TrDelay=zeros(length(Table)-length(x),1);
n=1;

for i=1:length(Table)
    if ismember(i,x)
        continue;
    else
        Training(n,[1:12])=Table(i,[1:12]);
        TrDelay(n)=Table(i,13);
        n=n+1;
    end
end


%% Fitting Tree

CostMatrix=[0 5;50 0];
TREE=fitctree(Training,TrDelay,'SplitCriterion','deviance','Prune','on','Cost',CostMatrix);
prediction=predict(TREE,Validation);
Error=VectorDiff(prediction,ValDelay);
view(TREE,'mode','graph');
ERRORRATE=zeros(1,21);

for i=1:length(ERRORRATE)
    prunedTREE=prune(TREE,'Level',i);
    ERRORRATE(i)=VectorDiff(predict(prunedTREE,Validation),ValDelay);
end

plot((1:length(ERRORRATE)),ERRORRATE);
title('Error Rate vs Prune Level');
xlabel('Prune Level');
ylabel('Error Rate');

%% Finding the best pruned tree

MeanError= mean(ERRORRATE);
stdev=std(ERRORRATE);

BestErrorRate=Inf;
for i=1:length(ERRORRATE)
    if ERRORRATE(i)<=BestErrorRate && ERRORRATE(i)>= (MeanError-1.5*stdev)
        BestErrorRate=ERRORRATE(i);
        BestPruneLevel=i;
    end
end

view(prune(TREE,'Level',BestPruneLevel),'mode','graph');
view(prune(TREE,'Level',BestPruneLevel))

errorcost=0;
mc1=0;
mc2=0;
for i=1:length(ValDelay)
    if ValDelay(i)>prediction(i)
        errorcost=errorcost+5;
        mc1=mc1+1;
    elseif ValDelay(i)<prediction(i)
        errorcost=errorcost+50;
        mc2=mc2+1;
    end
end