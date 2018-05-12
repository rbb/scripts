#!/bin/oct

x=[0:.1:120]; 
xl = max(20,x); % Anything less than 10 seconds is equivalent to 10 seconds

%y1=min(2,2-min(2,log10((x.^2)/400)));
%y=min(2,2-min(2,log10(((xl-10).^0.8)/1)));
%y=min(2,2.0-min(2,log10(((x+15).^2.0)/600)));
%y=min(2,2.0-min(2,log10(((xl-3).^1.0)/7)));
%y=min(2,2-min(5,log10(((x-18).^0.6)/1.5)));



%y1=log10((x.^2)/400);
%y=2-min(2,log10(((xl-10).^0.8)/1));
%y=log10(((x+10).^2.0)/100);
%y=log10(((xl-18).^.6)/1.5);
%y = 2-min(2,y) ;
%y=min(2,2-min(2,log10(((xl-18).^0.6)/1.5)));

y1=((x.^2)/400);
y1=max(0.25, y1);
y1=log10(y1);
y1 = min(2, 2-min(2,y1)) ;

%y=log10((x.^1.2)/40);
y=(x.^1.0)/10;
y=max(0.25, y);
y=log10(y);
y = min(2, 2-min(2,y)) ;

plot(x,y1,'b', x, y, 'r');
grid on;
ylim([0 2.1]);
set(gca, 'xtick', [0:10:120])
xlabel('rest (seconds)');
ylabel('Endurance adjustment Multiplier');
