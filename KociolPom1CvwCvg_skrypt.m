
clear all; close all;
%demo dla pomieszczenia z grzejnikem wodnym
model='KociolPom1CvwCvg';
%model='pom1kot_ss';
aparam1;
%wartoœci nominalne
%parametry instalacji w warunkach obliczeniowych
QgN = 2000;		%[W] 
QkN = QgN;
TzewN = -20;			%[C] (temperatura na zewn¹trz)
TwewN = 20;			%[C] (zadana temperatura wewnetrzna)
TgzN = 90;			%[C]  
TgpN = 70;			%[C] 
TkzN = TgzN;		%[C]  
TkpN = TgpN;		%[C] 

%parametry statyczne
FgN = QgN/(cpw*(TgzN-TgpN));	%[kg/s]
Kcg = QgN/(TgpN-TwewN);			%[W/K]
Kcw = QgN/(TwewN-TzewN);			%[W/K]

%parametry "dynamiczne" - aparam1
%==========================
%warunki pocz¹tkowe
Tzew0 = TzewN+0;	%+1
Qk0 = QkN;
Fg0 = FgN;
Fk0 = Fg0;
Qt0 = 0;
%stan równowagi
a = cpw*Fg0;
Twew0  = Qk0/Kcw + Tzew0;
Tgp0  = Qk0/Kcg + Twew0;
Tkz0  = Qk0/(cpw*Fk0) + Tgp0;

%do równañ stanu i r.statycznych X=Tgp, Twew
%u=[Tgz; Tz];	x=[Tw; Tgp], y=x
A = [(-Kcg-Kcw)/Cvws, Kcg/Cvws,                 0; ...
      Kcg/Cvg,                (-cpw*Fg0-Kcg)/Cvg, cpw*Fg0/Cvg; ...
	  0,                           cpw*Fg0/Cvk,             -cpw*Fg0/Cvk];
B = [0, Kcw/Cvws; 
       0, 0;  
       1/Cvk,        0];
C = [1, 0, 0; 0, 1, 0; 0, 0, 1]; D=[0,0;0,0;0,0];

u0 = [Qk0; Tzew0];					%u=[Tgz; Tz],
x0 = -A^(-1)*B*u0;
Twew0 = x0(1);Tgp0 = x0(2);Tkz0 = x0(3);			%x=[Tw; Tgp; Tkz], 
%==========================
%zak³ócenie
dQk = 0.2* QkN;
dTzew = 0;
dFg = 0*FgN;
dTgz = 0;
dQt = 0;
%==========================
%symulacja
%czas =8000;	czas_skok = 0;
%opcje = simget(model); %opcje = simset('MaxStep', tmax, 'RelTol',terr);
%[t] = sim(model, czas); 
%figure(1); hold on; grid on; title('Twew'); plot(t,aTwew,'m'),
%figure(2); hold on; grid on; title('Tkz, Tkp'); plot(t,aTkz,'r'), plot(t,aTgp,'b'), legend('Tjz', 'Tkp');
%figure(3); hold on; grid on; title('Twew(Qk)'); plot(aQk, aTwew, 'm'),
%figure(4); hold on; grid on; title('Qk(t)'); plot(t,aQk,'m');

%==========================
%symulacja
czas = 8000; czas_skok = 500;
opcje = simget(model); %opcje = simset('MaxStep', tmax, 'RelTol',terr);
[t] = sim(model, czas); 

%figure(1); hold on; grid on; title('Twew'); plot(t,aTwew,'m'),
%figure(2); hold on; grid on; title('Tkz, Tkp'); plot(t,aTkz,'r'), plot(t,aTgp,'b'), legend('Tjz', 'Tkp');
%figure(3); hold on; grid on; title('Twew(Qk)'); plot(aQk, aTwew, 'm'),
%figure(4); hold on; grid on; title('Qk(t)'); plot(t,aQk,'m');

% ============================================
% LAB 2 - METODA MOMENTÓW
% ============================================
Int0 = aInt0.Data(end);
Int1 = aInt1.Data(end);
Int2 = aInt2.Data(end);
Int3 = aInt3.Data(end);

% Wydrukuj dane momentów
fprintf('Int0: %.2f\n', Int0);
fprintf('Int1: %.2f\n', Int1);
fprintf('Int2: %.2f\n', Int2);
fprintf('Int3: %.2f\n', Int3);

% Macierz uk³adu równañ dla metody momentów
matrix1 = [0       0       1       0;
           Int0      0       0       -1;
           -Int1     Int0      0       0;
           0.5*Int2   -Int1     0       0];

matrix3 = [Int0;
            Int1;
            -0.5*Int2;
            (1/6)*Int3];

% Rozwi¹zanie uk³adu równañ
wspol = matrix1 \ matrix3;  % u¿ywaj \ zamiast ^(-1) dla stabilnoœci

a1 = wspol(1);
a2 = wspol(2);
b0 = wspol(3);
b1 = wspol(4);

% Wydrukuj wspó³czynniki transmitancji
fprintf('\nWspó³czynniki transmitancji:\n');
fprintf('a1: %.4f\n', a1);
fprintf('a2: %.4f\n', a2);
fprintf('b0: %.4f\n', b0);
fprintf('b1: %.4f\n', b1);

% Budowanie transmitancji
Tf_ident = tf([b1, b0], [a2, a1, 1]);
sys_org = ss(A, B, C, D);
Tf_org = tf(sys_org(1,1));

% Wyœwietl transmitancje
fprintf('\nTransmitancja identyfikowana:\n');
disp(Tf_ident);
fprintf('\nTransmitancja oryginalna:\n');
disp(Tf_org);

% ============================================
% WYKRES PORÓWNAWCZY DO SPRAWOZDANIA
% ============================================
t_plot = 0:10:6000;  % Zakres czasu do wykresu

% Oblicz odpowiedzi skokowe
[y_org, t_org] = step(Tf_org, t_plot);
[y_ident, t_ident] = step(Tf_ident, t_plot);

% Tworzenie wykresu
figure('Position', [100, 100, 800, 600]);  % Rozmiar okna wykresu
hold on; grid on;

% Rysowanie odpowiedzi
h1 = plot(t_org, y_org, 'r-', 'LineWidth', 2);
h2 = plot(t_ident, y_ident, 'b--', 'LineWidth', 2);

% Formatowanie wykresu
xlabel('Czas [s]', 'FontSize', 12);
ylabel('Wartoœæ odpowiedzi', 'FontSize', 12);
title('Porównanie modelu z oryginalem (METODA MOMENTÓW)', 'FontSize', 14, 'FontWeight', 'bold');
legend([h1, h2], {'Orygina³ (model SS)', 'Model z momentów'}, 'Location', 'best', 'FontSize', 11);

% Dodatkowe formatowanie
set(gca, 'FontSize', 10);
xlim([0, max(t_plot)]);
ylim([min([y_org; y_ident])*0.95, max([y_org; y_ident])*1.05]);

hold off;

% Opcjonalnie: zapisz wykres
% saveas(gcf, 'metoda_momentow.png');
% print('-dpng', '-r300', 'metoda_momentow_high_res.png');