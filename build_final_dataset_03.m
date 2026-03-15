%% SMART STIRRER FINAL DATASET BUILDER (34-COLUMN VERSION WITH BEAKER SIZE)
% One row per (base fraction, rpm, ml addition, beaker size) condition.
% Output label: visc_frac.

rootDir = '/Users/aaron/Desktop/UNI/year3/ES327/data/good_data';

viscFolders = dir(fullfile(rootDir, 'visc_frac*'));
viscFolders = viscFolders([viscFolders.isdir]);

allRows = table();

%% Exact base fraction mapping for 250 ml + 400 ml beakers
exactBaseFrac = @(x) ...
    (abs(x - 0.00) < 1e-6).*0 + ...
    (abs(x - 0.33) < 1e-6).*(1/3) + ...
    (abs(x - 0.55) < 1e-6).*(5/9) + ...
    (abs(x - 0.70) < 1e-6).*(19/27) + ...
    (abs(x - 0.40) < 1e-6).*(2/5) + ...
    (abs(x - 0.64) < 1e-6).*(16/25) + ...
    (abs(x - 0.78) < 1e-6).*(98/125);

%% Loop over viscosity folders
for v = 1:numel(viscFolders)

    viscFolderName = viscFolders(v).name;
    viscFolderPath = fullfile(rootDir, viscFolderName);

    % Parse base fraction
    fracTok = regexp(viscFolderName, 'visc_frac([0-9\.]+)_', 'tokens', 'once');
    if isempty(fracTok)
        fprintf('Skipping: cannot parse fraction in %s\n', viscFolderName);
        continue;
    end
    frac_dec = str2double(fracTok{1});
    base_frac = exactBaseFrac(frac_dec);

    % Parse base volume → beaker size
    volTok = regexp(viscFolderName, '_([0-9]+)ml', 'tokens', 'once');
    if isempty(volTok)
        fprintf('Skipping (no volume): %s\n', viscFolderName);
        continue;
    end

    base_vol = str2double(volTok{1});

    if base_vol == 100
        beaker_size = 250;
        max_extra_ml = 50;
    elseif base_vol == 150
        beaker_size = 400;
        max_extra_ml = 100;
    else
        fprintf('Unknown base volume %d ml in %s\n', base_vol, viscFolderName);
        continue;
    end

    % Compute base mixture volumes
    base_gly = base_frac * base_vol;
    base_wat = base_vol - base_gly;

    % RPM folders
    rpmFolders = dir(fullfile(viscFolderPath, 'RPM*'));
    rpmFolders = rpmFolders([rpmFolders.isdir]);

    for r = 1:numel(rpmFolders)

        rpmFolderName = rpmFolders(r).name;
        rpmFolderPath = fullfile(viscFolderPath, rpmFolderName);

        rpmTok = regexp(rpmFolderName, 'RPM(\d+)', 'tokens', 'once');
        if isempty(rpmTok), continue; end
        rpm_val = str2double(rpmTok{1});

        % ml folders
        mlFolders = dir(fullfile(rpmFolderPath, '*ml'));
        mlFolders = mlFolders([mlFolders.isdir]);

        for m = 1:numel(mlFolders)

            mlFolderName = mlFolders(m).name;
            mlFolderPath = fullfile(rpmFolderPath, mlFolderName);

            mlTok = regexp(mlFolderName, '(\d+)ml', 'tokens', 'once');
            if isempty(mlTok), continue; end

            extra_gly = str2double(mlTok{1});

            if extra_gly < 0 || extra_gly > max_extra_ml
                fprintf('Skipping invalid ml folder %s for beaker %d\n', mlFolderName, beaker_size);
                continue;
            end

            % Compute viscosity fraction
            total_gly = base_gly + extra_gly;
            total_vol = base_wat + total_gly;
            visc_frac = total_gly / total_vol;

            measFolder = fullfile(mlFolderPath, 'measurements');
            if ~isfolder(measFolder)
                fprintf('No measurements in %s\n', mlFolderPath);
                continue;
            end

            accelFile = fullfile(measFolder, 'accelerometer_data.csv');
            gyroFile  = fullfile(measFolder, 'gyroscope_data.csv');
            magFile   = fullfile(measFolder, 'magnetometer_data.csv');
            tempFile  = fullfile(measFolder, 'temperature_data.csv');

            if ~(isfile(accelFile) && isfile(gyroFile) && isfile(magFile) && isfile(tempFile))
                fprintf('Missing sensor files in %s\n', measFolder);
                continue;
            end

            %% Bulletproof sensor loading
            try
                A = readtable(accelFile);
                G = readtable(gyroFile);
                M = readtable(magFile);
                Tt = readtable(tempFile);
            catch
                fprintf('readtable failed in %s\n', measFolder);
                continue;
            end

            % Validate accel/gyro/mag
            if width(A) < 4 || height(A) < 10, fprintf('Bad accel in %s\n', measFolder); continue; end
            if width(G) < 4 || height(G) < 10, fprintf('Bad gyro in %s\n', measFolder); continue; end
            if width(M) < 4 || height(M) < 10, fprintf('Bad magnet in %s\n', measFolder); continue; end

            % Validate temperature
            if width(Tt) < 2 || height(Tt) < 1
                fprintf('Bad temperature in %s\n', measFolder);
                continue;
            end

            temp_col = Tt{:,2};
            if isempty(temp_col) || ~isnumeric(temp_col)
                fprintf('Invalid temperature column in %s\n', measFolder);
                continue;
            end

            temp_mean = mean(temp_col);

            %% Compute IMU statistics
            ax=A{:,2}; ay=A{:,3}; az=A{:,4};
            gx=G{:,2}; gy=G{:,3}; gz=G{:,4};
            mx=M{:,2}; my=M{:,3}; mz=M{:,4};

            % Build row
            row = table();

            row.visc_frac = visc_frac;
            row.beaker_size = beaker_size;
            row.rpm = rpm_val;
            row.temp_mean = temp_mean;

            row.accelX_mean = mean(ax); row.accelX_std = std(ax); row.accelX_rms = sqrt(mean(ax.^2));
            row.accelY_mean = mean(ay); row.accelY_std = std(ay); row.accelY_rms = sqrt(mean(ay.^2));
            row.accelZ_mean = mean(az); row.accelZ_std = std(az); row.accelZ_rms = sqrt(mean(az.^2));

            row.gyroX_mean = mean(gx); row.gyroX_std = std(gx); row.gyroX_rms = sqrt(mean(gx.^2));
            row.gyroY_mean = mean(gy); row.gyroY_std = std(gy); row.gyroY_rms = sqrt(mean(gy.^2));
            row.gyroZ_mean = mean(gz); row.gyroZ_std = std(gz); row.gyroZ_rms = sqrt(mean(gz.^2));

            row.magnX_mean = mean(mx); row.magnX_std = std(mx); row.magnX_rms = sqrt(mean(mx.^2));
            row.magnY_mean = mean(my); row.magnY_std = std(my); row.magnY_rms = sqrt(mean(my.^2));
            row.magnZ_mean = mean(mz); row.magnZ_std = std(mz); row.magnZ_rms = sqrt(mean(mz.^2));

            row.source_folder = string(viscFolderName);
            row.rpm_folder = string(rpmFolderName);
            row.ml_folder = string(mlFolderName);

            allRows = [allRows; row];
        end
    end
end

%% Save dataset
save('final_dataset.mat','allRows');
writetable(allRows,'final_dataset.csv');

fprintf('\n==========================================\n');
fprintf(' DATASET BUILT SUCCESSFULLY (%d rows)\n',height(allRows));
fprintf(' Saved as final_dataset.mat & final_dataset.csv\n');
fprintf('==========================================\n\n');
