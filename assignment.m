pkg load signal;
close all;
clear;

[ynoisy,fs_noisy] = audioread('noisy_signal.wav');
[y,fs] = audioread('clean_signal.wav');



########################### noisy ##########################################
N_noisy = length(ynoisy);
slength_noisy = N_noisy/fs_noisy; %the length of audio signal in sec

t_noisy = linspace(0, slength_noisy, N_noisy);

figure;
plot(t_noisy,ynoisy); %checking the signal in cont. time domain
xlabel('Time, sec');
ylabel('Amplitude');
title('Noisy Signal in cont. time domain');


%doing DFT to obtain frequency spectra
YNOISY = fft(ynoisy);
Mag_YNOISY = abs(YNOISY);
Mag_YNOISY = fftshift(Mag_YNOISY);

df_noisy = fs_noisy/N_noisy;
w_noisy = (-(N_noisy/2):(N_noisy/2)-1)*df_noisy; % xaxis setting for frequency response graph

figure;
stem(w_noisy, Mag_YNOISY/N_noisy); %normalize to num_samples
xlabel('Frequency,Hz');
ylabel('Magnitude');
title('Noisy Frequency Spectra graph');

############################# clean ########################################
N = length(y);
slength = N/fs;

t= linspace(0,slength,N);

figure;
plot(t,y);
xlabel('Time, sec');
ylabel('Amplitude');
title('Clean Signal in cont. time domain');

%doing dft to obtain freq spectra
Y = fft(y);
Mag_Y = abs(Y);
Mag_Y = fftshift(Mag_Y);

df = fs/N;
w = (-(N/2):(N/2)-1)*df;

figure;
stem(w, Mag_Y/N_noisy);
xlabel('Frequency,Hz');
ylabel('Magnitude');
title('Clean Frequency Spectra Graph');

########################### Designing FIR filter #################################
numFreq =512;
tap = 199; %tolerating 50hz of transition width freq for lower and upper
fL = 6729.13; %low cutoff  freq of 6730 Hz
fH = 10093.7; %upper corner freq of 10093.5 Hz
M = tap-1;
Wn_L = fL/(fs_noisy/2); %stop band normalize to fs
Wn_H = fH/(fs_noisy/2); %pass band normalize to fs

Bfir = fir1(M,[Wn_L,Wn_H],'stop',rectwin(tap),'noscale');
figure;
freqz(Bfir,1,numFreq,fs_noisy);

%###########################  applying filter #####################################
xnoisy = filter(Bfir,1,ynoisy);
figure;
plot(t_noisy,xnoisy);
xlabel('Time, sec');
ylabel('Amplitude');
title('Filtered Noisy in cont. time domain');

XNOISY = fft(xnoisy);
Mag_XNOISY = abs(XNOISY);
Mag_XNOISY = fftshift(Mag_XNOISY);
figure;
stem(w_noisy, Mag_XNOISY/N_noisy);
xlabel('Frequency,Hz');
ylabel('Magnitude');
title('Filtered Noisy Frequency Spectra graph');


############################ Designing IIR filter ###############################
fstop = [6729.13 10093.7];
fpass = [6429.13 11025]; % fpass = [6429.13 11025];
Rpass = 3;
Rstop = 14;
Wpass = fpass/(fs_noisy/2);
Wstop = fstop/(fs_noisy/2); %normalizing to fs

[order Wn_p Wn_s] = buttord(Wpass, Wstop, Rpass, Rstop);
[B_butt A_butt] = butter(order,Wn_s,'stop');

figure;
freqz(B_butt,A_butt,numFreq,fs_noisy);

%###########################  applying filter #####################################
xnoisy = filter(B_butt,A_butt,ynoisy);
figure;
plot(t_noisy,xnoisy);
xlabel('Time, sec');
ylabel('Amplitude');
title('Filtered Noisy in cont. time domain');

XNOISY = fft(xnoisy);
Mag_XNOISY = abs(XNOISY);
Mag_XNOISY = fftshift(Mag_XNOISY);
figure;
stem(w_noisy, Mag_XNOISY/N_noisy);
xlabel('Frequency,Hz');
ylabel('Magnitude');
title('Filtered Noisy Frequency Spectra graph');




