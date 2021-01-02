% Alireza Goli
function S = extract_proj(W_image, B, a, K)

[W_image_row_size, W_image_col_size] = size(W_image);

% Calculating the number of B*B blocks in W_image
number_of_blocks = (W_image_row_size/B) * (W_image_col_size/B);

% Initializing coef_block, extracted string and its index 
coef_block = zeros(B, B);
extracted_string = logical(zeros(number_of_blocks,1));
m=1;

% Extracting logo from W_image based on this rule: if coef_block(a+1, a) > coef_block(a, a+1) then data=1 else data=0
for i=1:B:W_image_row_size
    
    for j=1:B:W_image_col_size
        
        coef_block = dct2(W_image(i:i+B-1, j:j+B-1));
        
        % (a+1, a) > (a, a+1) then data=1
        if coef_block(a+1, a) > coef_block(a, a+1)
            extracted_string(m,1) = 1;
        else
            extracted_string(m,1) = 0;
        end
        
         m= m+1;
         
    end
                   
end


% Giving K as a seed to be used in randperm function
rand('seed',K);
% Calculating random permutation of  indexes in W1D based on key K
indexes=randperm(size(extracted_string,1));
% Decoding string based on indexes
extracted_string(indexes)= extracted_string;

% Output
S=extracted_string;

end