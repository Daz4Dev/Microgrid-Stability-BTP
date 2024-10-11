% Define the range of 'mp' and 'nq' values
mp_values = linspace(1.57e-5, 3.14e-4, 10); 
nq_values = linspace(3.17e-4, 4.8e-3, 10); 

% Nested loops for Cartesian product of 'mp' and 'nq'
for index1 = 1:length(mp_values)
    for index2 = 1:length(nq_values)
        % Assign current 'mp_v' and 'nq_v' values
        mp_v = mp_values(index1);
        nq_v = nq_values(index2);
        
        % Run the main script (to generate necessary data)
        MAIN; 
        
        % Retrieve the 'tout' variable from the workspace
        tout = evalin('base', 'tout');  % Time data from workspace
        
        % Initialize arrays for storing current and voltage data
        current_data = zeros(10004, 18); % 3 inverters, 3 phases, 2 components each (magnitude and phase)
        voltage_data = zeros(10004, 18); % 3 inverters, 3 phases, 2 components each (magnitude and phase)

        % Retrieve the I and V data from the workspace
        for index3 = 1:3  % For each inverter
            for index4 = 1:3  % For each phase
                % Construct the variable names
                current_mag_var = sprintf('INV_%d_I_%c_m', index3, 'a' + index4 - 1);
                current_phase_var = sprintf('INV_%d_I_%c_p', index3, 'a' + index4 - 1);
                voltage_mag_var = sprintf('INV_%d_V_%c_m', index3, 'a' + index4 - 1);
                voltage_phase_var = sprintf('INV_%d_V_%c_p', index3, 'a' + index4 - 1);
                
                % Retrieve the data as timeseries objects
                current_mag_data = evalin('base', current_mag_var);
                current_phase_data = evalin('base', current_phase_var);
                voltage_mag_data = evalin('base', voltage_mag_var);
                voltage_phase_data = evalin('base', voltage_phase_var);
                
                % Convert timeseries to numeric arrays
                current_mag_array = current_mag_data.Data; % Convert to numeric
                current_phase_array = current_phase_data.Data; % Convert to numeric
                voltage_mag_array = voltage_mag_data.Data; % Convert to numeric
                voltage_phase_array = voltage_phase_data.Data; % Convert to numeric

                % Calculate the column index for currents and voltages
                % Each inverter-phase combination contributes 2 columns (magnitude + phase)
                current_col_index = (index3 - 1) * 6 + (index4 - 1) * 2; 
                voltage_col_index = (index3 - 1) * 6 + (index4 - 1) * 2; 
                
                % Store the data into respective arrays
                current_data(:, current_col_index + 1) = current_mag_array; % Magnitude
                current_data(:, current_col_index + 2) = current_phase_array; % Phase

                % Store the voltage data
                voltage_data(:, voltage_col_index + 1) = voltage_mag_array; % Magnitude
                voltage_data(:, voltage_col_index + 2) = voltage_phase_array; % Phase
            end
        end
        
        % Combine tout, current, and voltage data into a single matrix
        output_data = [tout, current_data, voltage_data];
        
        % Generate variable names for the CSV files
        csv_filename = sprintf('data_mp_%02d_nq_%02d.csv', index1, index2);
        
        % Save the combined data to a CSV file
        csvwrite(csv_filename, output_data);
        
        % Retrieve eigenvalues and save in a separate CSV
        eigenvalues = evalin('base', 'E');  % Adjust variable name as needed
        eigenvalues_filename = sprintf('eigenvalues_mp_%02d_nq_%02d.csv', index1, index2);
        csvwrite(eigenvalues_filename, eigenvalues);
        
        % Print statement for data saved
        fprintf('CSV for mp = %.2e and nq = %.2e has been saved as %s\n', mp_v, nq_v, csv_filename);
    end
end
