Parameters;
sim('TCGreen.slx');

xinv = [xinv1;xinv2;xinv3];
Iline = reshape(Iline,3,n);
% Iload = reshape(Iload,3,n);
Vb = reshape(Vb,3,m);

%for MP=(0.157:3.14)*1e-4
%    mp(:)=1.1*1e-4;
%% All Inverters

% fetch 'mp_v' and 'nq_v' from the base workspace
mp_temp = evalin('base', 'mp_v');
nq_temp = evalin('base', 'nq_v');


mp(:) = mp_temp;
nq(:) = nq_temp;


% Reference Inverter
[A,B1,C1,C2] = Ref_Inverter(rf(1), Lf(1), Cf(1), rc(1), Lc(1), mp(1), nq(1), wc(1), Kpv(1), Kiv(1), F(1), Kpc(1), Kic(1), Vn, wn, Vb(1,invbus(1)), Vb(2,invbus(1)), xinv(1,:));
A_INV = A;
B_INV = B1;
C_INV = C1;
B2_INV = [];

% Other Inverters
for i=2:s
    [A,B1,B2,C] = Inverter(rf(i), Lf(i), Cf(i), rc(i), Lc(i), mp(i), nq(i), wc(i), Kpv(i), Kiv(i), F(i), Kpc(i), Kic(i), Vn, wn, Vb(1,invbus(i)), Vb(2,invbus(i)), xinv(i,:));
    A_INV = blkdiag(A_INV,A);
    B_INV = blkdiag(B_INV,B1);
    C_INV = blkdiag(C_INV,C);
    B2_INV = [B2_INV;B2];
end
A_INV = A_INV + [zeros(13,13*s); B2_INV*C2, zeros(13*(s-1))];
B_INV = B_INV*M_INV;
Cw_INV = [C2, zeros(1,13*(s-1))];

%% All Lines
A_LINE=[]; B_LINE=[]; B2_LINE=[];
for i=1:n
    [A,B,B2] = Line(Rline(i),Lline(i),wn,Iline(1,i),Iline(2,i));
    A_LINE = blkdiag(A_LINE,A);
    B_LINE = blkdiag(B_LINE,B);
    B2_LINE = [B2_LINE;B2];
end
B_LINE = B_LINE*(-M_LINE);

%% All RL Loads
% A_LOAD=[]; B_LOAD=[]; B2_LOAD=[];
% for i=1:n
%     [A,B,B2] = RL_Load(Rload(i),Lload(i),wn,Iload(1,i),Iload(2,i));
%     A_LOAD = blkdiag(A_LOAD,A);
%     B_LOAD = blkdiag(B_LOAD,B);
%     B2_LOAD = [B2_LOAD;B2];
% end
% B_LOAD = B_LOAD*(-M_LOAD);

%% Overall System

% % RL load
% A_MG = [A_INV+B_INV*Rv*M_INV'*C_INV,                B_INV*Rv*M_LINE',               B_INV*Rv*M_LOAD';
%         B_LINE*Rv*M_INV'*C_INV+B2_LINE*Cw_INV,      A_LINE+B_LINE*Rv*M_LINE',       B_LINE*Rv*M_LOAD';
%         B_LOAD*Rv*M_INV'*C_INV+B2_LOAD*Cw_INV,      B_LOAD*Rv*M_LINE',              A_LOAD+B_LOAD*Rv*M_LOAD'];

% R load
A_MG = [A_INV+B_INV*Rv*M_INV'*C_INV,                B_INV*Rv*M_LINE';
        B_LINE*Rv*M_INV'*C_INV+B2_LINE*Cw_INV,      A_LINE+B_LINE*Rv*M_LINE'];
[ E,PF ] = Participation( A_MG );
plot(real(E),imag(E),'*');hold on;
grid on; xlim([-5000,inf])

%end








