% Alireza Goli
function W_image= embed_proj(I, B, a, W2D, K ,alpha)

[I_row_size, I_col_size]= size(I);

% Checking size of I to be dividable by B
if mod(I_row_size, B)~=0 || mod(I_col_size, B)~=0
    
    new_I_row_size= I_row_size + (B-mod(I_row_size, B));
    new_I_col_size= I_col_size + (B-mod(I_col_size, B));
    
    % Resize I to a new size that is dividable by B
    I=imresize(I, [new_I_row_size, new_I_col_size], 'bicubic');
    [I_row_size, I_col_size]= size(I);
    
end
    
% Calculating the number of B*B blocks in I     
number_of_blocks= (I_row_size/B)* (I_col_size/B);

% Checking the number of bits in W2D to be equal to the number of B*B blocks in I 
if number_of_blocks ~= size(W2D(:), 1)
    
    % Resize W2D to a new size so that numebr of bits in W2D is equal to number of B*B blocks in I 
    W2D=imresize(W2D, [I_row_size/B, I_col_size/B] , 'bicubic');
    
end

% Converting W2D to binary image
treshhold=graythresh(W2D);
W2D=im2bw(W2D, treshhold);

% Converting W2D to a column vector (W1D) and cacluatiing size of W1D
W1D= W2D(:);
W1D_size= size(W1D,1);

% Giving K as a seed to be used in randperm function
rand('seed',K);
% Calculating a random permutation of  indexes in W1D 
shuffled_indexes=randperm(W1D_size);
% Shuffling W1D according to random indexes
shuffled_W1D= W1D(shuffled_indexes);

% Initializing coef_block and W_image and index of W1D
coef_block= zeros(B,B);
W_image= uint8(zeros(I_row_size, I_col_size)); 
m=1;

% Calculating dct coefficients for B*B block and embeding W1D in I based on
% this rule: if coef_block(a+1, a) > coef_block(a, a+1) then data=1 else data=0
for i=1:B:I_row_size
    
    for j=1:B:I_col_size
        
        % Calculating dct coefficient for a B*B block
        coef_block = dct2(I(i:i+B-1, j:j+B-1));
        % Difference between coefficients
        difference=0;
        
        % Embeding 1
        if shuffled_W1D(m)==1
            
            if coef_block(a+1, a) > coef_block(a, a+1)
                
                % Calculationg difference between coefficients
                difference = coef_block(a+1, a) - coef_block(a, a+1);
                
                % Cheking to make sure that difference between (a+1, a) and (a, a+1) is enough (equal to alpha) or not 
                if difference < alpha
                    coef_block(a+1, a) = coef_block(a+1, a) + ((alpha-difference)/2);
                    coef_block(a, a+1) = coef_block(a, a+1) - ((alpha-difference)/2);
                end
                
            else
                
                % Swaping (a+1, a) and (a, a+1)
                temp = coef_block(a+1, a);
                coef_block(a+1, a)= coef_block(a, a+1);
                coef_block(a, a+1) = temp;
                
                % Calculationg difference between coefficients
                difference = coef_block(a+1, a) - coef_block(a, a+1);
                
                % Cheking to make sure that difference between (a+1, a) and (a, a+1) is enough (equal to alpha) or not 
                if difference< alpha
                    coef_block(a+1, a) = coef_block(a+1, a) + ((alpha-difference)/2);
                    coef_block(a, a+1) = coef_block(a, a+1) - ((alpha-difference)/2);
                end
            end 
            
        % Embeding 0
        else
            
            if coef_block(a+1, a) <= coef_block(a, a+1)
                
                % Calculationg difference between coefficients
                difference = coef_block(a, a+1) - coef_block(a+1, a);
                
                % Cheking to make sure that difference between (a+1, a) and (a, a+1) is enough (equal to alpha) or not
                if difference< alpha
                    coef_block(a, a+1) = coef_block(a, a+1) + ((alpha-difference)/2);
                    coef_block(a+1, a) = coef_block(a+1, a) - ((alpha-difference)/2);
                end
                
            else
                
                % Swaping (a+1, a) and (a, a+1)
                temp=coef_block(a, a+1);
                coef_block(a, a+1)= coef_block(a+1, a);
                coef_block(a+1, a) = temp;
                
                % Calculationg difference between coefficients
                difference = coef_block(a, a+1) - coef_block(a+1, a);
                
                % Cheking to make sure that difference between (a+1, a) and (a, a+1) is enough (equal to alpha) or not
                if difference< alpha
                    coef_block(a, a+1) = coef_block(a, a+1) + ((alpha-difference)/2);
                    coef_block(a+1, a) = coef_block(a+1, a) - ((alpha-difference)/2);
                end
                
            end
            
        end
        
       % Calculating inverse DCT and puting result in W_image
       W_image(i:i+B-1, j:j+B-1)= uint8(idct2(coef_block));
       
       m= m+1;
       
    end
end

% Calculating PSNR
disp('PSNR:');
disp(psnr(W_image, I, 255));

end