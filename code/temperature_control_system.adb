pragma SPARK_Mode (On);
with AS_IO_Wrapper; use AS_IO_Wrapper;

package body Temperature_Control_System is
   
   -- Get the gain divisor, must be input from the user and must be between the limits
   procedure GetGainDivisor is 
      GainDivisor : Integer;
   begin
      AS_Put("Enter the gain divisor of the system (");
      AS_Put(Gain_Divisor_Min);
      AS_Put(" - ");
      AS_Put(Gain_Divisor_Max);
      AS_Put("): ");
      loop
         AS_Get(GainDivisor, "Enter the gain divisor");
         exit when (GainDivisor >= Gain_Divisor_Min) and (GainDivisor <= Gain_Divisor_Max);
         AS_Put("The gain divisor must be >=");
         AS_Put(Gain_Divisor_Min);
         AS_Put(" and >=");
         AS_Put(Gain_Divisor_Max);
         AS_Put(": ");
      end loop;
      System_Status.Gain_Divisor := Gain_Divisor_Range(GainDivisor);
   end GetGainDivisor;
   
   
   -- Get the minimum temperature, must be input from the user and must be between the absolute temp limits
   procedure GetMinTempRange is 
      Temperature : Integer;
   begin
      AS_Put("Enter the lower temperature limit of the system (>=");
      AS_Put(Absolute_Min_Temp);
      AS_Put(" and <");
      AS_Put(Absolute_Max_Temp);
      AS_Put("): ");
      loop
         AS_Get(Temperature, "Enter lower temp limit");
         exit when (Temperature >= Absolute_Min_Temp) and (Temperature < Absolute_Max_Temp);
         AS_Put("The lower temperature must be >=");
         AS_Put(Absolute_Min_Temp);
         AS_Put(" and <");
         AS_Put(Absolute_Max_Temp);
         AS_Put(": ");
      end loop;
      System_Status.Lower_Temp_Limit := Temperature;
   end GetMinTempRange;
   
   
   -- Get the maximum temperature, must be input from the user and must be between the absolute temp limits
   procedure GetMaxTempRange is 
      Temperature : Integer;
   begin
      AS_Put("Enter the upper temperature limit of the system (>");
      AS_Put(System_Status.Lower_Temp_Limit);
      AS_Put(" and <=");
      AS_Put(Absolute_Max_Temp);
      AS_Put("): ");
      loop
         AS_Get(Temperature, "Enter upper temp limit");
         exit when (Temperature <= Absolute_Max_Temp) and (Temperature > System_Status.Lower_Temp_Limit);
         AS_Put("The upper temperature must be >");
         AS_Put(System_Status.Lower_Temp_Limit);
         AS_Put(" and <=");
         AS_Put(Absolute_Max_Temp);
         AS_Put("): ");
      end loop;
      System_Status.Upper_Temp_Limit := Temperature;
   end GetMaxTempRange;
   
   
   -- Get the current temperature, must be input from the user and between the upper and lower limits
   procedure ReadCurrentTemp is
      Temperature : Integer;
   begin
      AS_Put("Enter the current temperature of the system (");
      AS_Put(System_Status.Lower_Temp_Limit);
      AS_Put(" - ");
      AS_Put(System_Status.Upper_Temp_Limit);
      AS_Put("): ");
      loop
         AS_Get(Temperature, "Enter the current temp");
         exit when Temperature in System_Status.Lower_Temp_Limit .. System_Status.Upper_Temp_Limit;
         AS_Put("The current temperature must be between");
         AS_Put(System_Status.Lower_Temp_Limit);
         AS_Put(" and");
         AS_Put(System_Status.Upper_Temp_Limit);
         AS_Put(": ");
      end loop;
      System_Status.Current_Temp := Temperature;
   end ReadCurrentTemp;
   
   
   -- Calculates and guides the temperature towards the midpoint
   procedure ControlTemp is
      error : Integer;  -- positive = current too high, negative = current too low
   begin
      error := ((System_Status.Lower_Temp_Limit + System_Status.Upper_Temp_Limit) / 2) - System_Status.Current_Temp;
      System_Status.Temp_Control := error / System_Status.Gain_Divisor;
      AS_Put_Line;
      AS_Put("Appling ");
      AS_Put(System_Status.Temp_Control);
      AS_Put(" temperature change to the system...");
      AS_Put_Line("");
      System_Status.Current_Temp := System_Status.Current_Temp + System_Status.Temp_Control;
   end ControlTemp;
   
   
   -- Get system type (automatic / manual) for temperature adjustment
   procedure GetSystemMethod is
      SystemMethod : String(1..20);
      last : Integer;
   begin
      loop -- Automatic / manual choice
         AS_Put("Manual temperature adjustment? (y/n)?:");
         AS_Get_Line(SystemMethod, last);
         AS_Put_Line;
         exit when last > 0 and (SystemMethod(1..1) = "n" or SystemMethod(1..1) = "y");
      end loop;
   
      if SystemMethod(1..1) = "y" then
         System_Status.System_Method := Manual;
      else
         System_Status.System_Method := Automatic;
      end if;
   end GetSystemMethod;
      
   
   -- Print the current temperature
   procedure PrintTempStatus is
   begin
      AS_Put("Current Temperature = ");
      AS_Put(Temperature_Range'Image(System_Status.Current_Temp));
      AS_Put_Line;
   end PrintTempStatus;
   
   
   -- Check if the system is complete (no changes are being made to the temperature)
   function isComplete return Boolean is
   begin
      return System_Status.Temp_Control = 0;
   end isComplete;
            
   
   -- Initialise the input, output and system status to default values.
   procedure Init is
   begin
      AS_Init_Standard_Input;
      AS_Init_Standard_Output;
      System_Status := (Gain_Divisor => Gain_Divisor_Min,
                        Current_Temp => Absolute_Min_Temp,
                        Lower_Temp_Limit => Absolute_Min_Temp,
                        Upper_Temp_Limit => Absolute_Max_Temp,
                        Temp_Control => 0,
                        System_Method => Manual,
                        Is_Initialised => True);
                        
   end Init;
   

end Temperature_Control_System;
