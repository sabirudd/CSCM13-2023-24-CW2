pragma SPARK_Mode (On);
with AS_IO_Wrapper, Temperature_Control_System; use AS_IO_Wrapper, Temperature_Control_System;

procedure Main is
   input_string : String(1..20);
   last : Integer;
begin
   Init;
   
   -- Get initial input values
   GetSystemMethod;
   GetGainDivisor;
   GetMinTempRange;
   GetMaxTempRange;
   ReadCurrentTemp; 
   
   loop -- Main loop
      
      loop -- Control signal calculation loop
         AS_Put_Line;
         ControlTemp;
         PrintTempStatus;
         
         if isComplete then
            return;
         end if;
         
         if System_Status.System_Method = Manual then
            loop -- Ask user if continue with same config
               AS_Put("Continue with current configuration (y/n)?:");
               AS_Get_Line(input_string, last);
               AS_Put_Line;
               exit when last > 0;
            end loop;
            exit when input_string(1..1) = "n";
            AS_Put_Line;
         end if;
      end loop;
   

      if System_Status.System_Method = Manual then
         loop -- Ask user if new limits
            AS_Put("Continue new limits (y/n)?:");
            AS_Get_Line(input_string, last);
            AS_Put_Line;
            exit when last > 0;
         end loop;
         exit when input_string(1..1) = "n";
      end if;
         
      AS_Put_Line;

      GetMinTempRange;
      GetMaxTempRange;
      PrintTempStatus;
   end loop;
   AS_Put("Temperature Control Completed!");
end Main;
