close all
% clear all
clc

% the file is a stereo audio signal. That's why x has two columns
% Fe is the sampling frequency used by default by MATLAB 
[x,Fe] = audioread('HaydnL.wav');

% We take the average of the stereo signal 
y = 1/2*(x(:,1) + x(:,2));

% sound is a command to hear the music 
sound(y,Fe);

Te  = 1/Fe; 
tt = 0:Te:length(y)*Te - Te; 

% disp(length(y))
disp(length(x))

figure
plot(tt,y)
xlabel('time in s')
ylabel('MATLAB-sampled signal')

M = 2^8; 
fsig = (0:M-1)*Fe/M; 
SigFFT = abs(fft(y,M));

figure
plot(fsig/1e3, SigFFT)
xlabel('frequency in KHz')
ylabel('fft of the signal')
title('Spectrum of the audio signal')


%% Sub-sampling 

% Choose different values for the parameters k = 4, 8, 16 
k = 4; % try k = 4, 8 and 16
Fek = Fe/k;
ye = y(1:k:end);
sound(ye,Fek);


% The fourier transform of the signal 
fsig = (0:M-1)*Fek/M; 
SigFFT = abs(fft(ye,M));

tt1 = 0:1/Fek:length(ye)/Fek - 1/Fek; 

figure
plot(fsig/1e3, SigFFT)
xlabel('frequency in kHz')
ylabel('Sub-sampled signal')
title('Spectrum of the sub-sampled signal')
%% Quantization 
% Change Nlevel 
Nlevel = 2^6; % try Nlevel = 2^4 and 2^6

% ye is the sub-sampled signal 
ymax = max(ye);
ymin = min(ye);
%  quantization step 
q = (ymax - ymin)/(Nlevel - 1);

% quantified signal = the levels 
V = round(ye/q);
sound(V*q,Fek);

figure
plot(tt1,V*q); 
xlabel('time in s')
ylabel('Sub-sampled signal')


%% Conversion binaire
Vbis = V - min(V);
% Uniform coding 
datastream = de2bi(Vbis);
stream_total = reshape(datastream',1,[]);
lstream_total = length(stream_total);


%% Huffman coding
pV = zeros(1,Nlevel); 

% Find the probability of occurence of each quantization level 
for k = 0:Nlevel-1
    pV(k+1) = length(find(Vbis == k))/length(Vbis); 
end

s = 0:Nlevel-1; 

% The Huffman dictionary 
dict = huffmandict(s, pV); 

% Encode with the Huffman dictionary 
bin_stream = huffmanenco(Vbis, dict); 
lHuffman = length(bin_stream)


