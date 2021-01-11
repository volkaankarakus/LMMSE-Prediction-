%% Ses Kaydı
recObj = audiorecorder;
disp('Start speaking.')
recordblocking(recObj,3);
disp('End of Recording.');
play(recObj);
x = getaudiodata(recObj); % Store Data in double-precision array,y
plot(x);

%% Matris Hesaplamalari
a=length(x);
N1=128;
data=x(1:N1); % Quantize İcin Bunu State Tuttum. 
Rx=zeros(1,N1);

for k=1:1:N1
    for n=1:1:N1-1-k
        Rx(k)=(1/N1).*(sum(x(n).*x(n+k)));
    end
end

%% 16x16'lik RHatX ve 16x1'lik aHatX' in carpımı = rHatx
RHatX=toeplitz(Rx);
rHatX=Rx';
aHatX=zeros(N1,1);
aHatX=RHatX\rHatX; % Ax=B için x'in Gauss Jordan'ı. 
% a'lar bulundu. -> (aHatX)

%% k Kadar Degerde 8-Bit Quantization
K=8;
quantized8bit=floor(data*(1-eps)*2^K)/2^K;
%quantized8bit=quantized8bit.'; % Predict carpiminda 
                               %a'lar dikey oldugu icin dataların 
                               % yatay olması icin transra;

%% Prediction
%N1=128 alinirsa ve 129. degeri tahmin edeceksek :
% predictdata=a(1).x[n-1]+a(2).x[n-2]....a(k).x[n-k]
predictdata=(aHatX')*quantized8bit; % N1+1'inci tahmini degeri buldum. 
%% Error Hesabı
datahatasi=(x(17))-predictdata; % N1+1. bit icin hata=gercek deger-tahmin

%% Error 5-Bit Quantize
K=5;
hataquantized5bit=floor(datahatasi*(1-eps)*2^K)/2^K;

%% Yeni N1+1. Data
% quantizehata + tahmin degeri'nin gercek degeri vermesini bekleriz.

Xp=hataquantized5bit + predictdata; %N1+1. deger icin
                                    %tahmin elde ettik.


%% Yeni Vektor 
data(end+1)=Xp; %Ilk N1 degeri orjinal,son degeri tahminle bulunan 
                % vektoru olusturdum.
                

