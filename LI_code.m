function LI = LI_code(Matrix_ROI)
    n_subj = size(Matrix_ROI, 1);
    n_ROI = size(Matrix_ROI, 2) / 2; 
    LI = zeros(n_subj, n_ROI); 
    for ii = 1:n_ROI  
        sx = Matrix_ROI(:, 2*ii-1);
        dx = Matrix_ROI(:, 2*ii); 
        LI(:, ii) = (dx - sx) ./ (dx + sx);
        clear sx
        clear dx
    end
    clear ii
end

