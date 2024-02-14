pragma SPARK_Mode (On);
with SPARK.Text_IO; use SPARK.Text_IO;

package Temperature_Control_System is
   
   Absolute_Max_Temp : constant Integer := 1000;
   Absolute_Min_Temp : constant Integer := -1000;
   Gain_Divisor_Max : constant Integer := 10;
   Gain_Divisor_Min : constant Integer := 2;
   
   subtype Gain_Divisor_Range is Integer range Gain_Divisor_Min .. Gain_Divisor_Max;
   subtype Temperature_Range is Integer range Absolute_Min_Temp .. Absolute_Max_Temp;
   
   type System_Method_Type is (Manual, Automatic);
   
   type System_Status_Type is
      record
         Gain_Divisor : Gain_Divisor_Range;
         Current_Temp : Temperature_Range;
         Lower_Temp_Limit : Temperature_Range;
         Upper_Temp_Limit : Temperature_Range;  
         Temp_Control : Temperature_Range;
         System_Method : System_Method_Type;
         Is_Initialised : Boolean;
      end record;
      
   System_Status : System_Status_Type;
      
   
   procedure GetGainDivisor with
     Global => (In_Out => (Standard_Output, Standard_Input, System_Status)),
     Depends => (Standard_Output => (Standard_Output, Standard_Input),
                 Standard_Input  => Standard_Input,
                 System_Status   => (System_Status, Standard_Input)),
     Pre => (System_Status.Gain_Divisor >= Gain_Divisor_Min) and
            (System_Status.Gain_Divisor <= Gain_Divisor_Max) and
            (Gain_Divisor_Min < Gain_Divisor_Max),
     Post => (System_Status.Gain_Divisor >= Gain_Divisor_Min) and
             (System_Status.Gain_Divisor <= Gain_Divisor_Max);
                                    
   
   procedure GetMinTempRange with
     Global => (In_Out => (Standard_Output, Standard_Input, System_Status)),
     Depends => (Standard_Output => (Standard_Output, Standard_Input),
                 Standard_Input  => Standard_Input,
                 System_Status   => (System_Status, Standard_Input)),
     Pre => (System_Status.Lower_Temp_Limit >= Absolute_Min_Temp) and
            (Absolute_Min_Temp < Absolute_Max_Temp),
     Post => (System_Status.Lower_Temp_Limit >= Absolute_Min_Temp) and
             (System_Status.Lower_Temp_Limit < Absolute_Max_Temp);
   
   
   procedure GetMaxTempRange with
     Global => (In_Out => (Standard_Output, Standard_Input, System_Status)),
     Depends => (Standard_Output => (Standard_Output, Standard_Input, System_Status),
                 Standard_Input  => (Standard_Input, System_Status),
                 System_Status   => (System_Status, Standard_Input)),
     Pre => (Absolute_Max_Temp >= System_Status.Upper_Temp_Limit) and
            (Absolute_Min_Temp < Absolute_Max_Temp),
     Post => (System_Status.Upper_Temp_Limit > System_Status.Lower_Temp_Limit) and
             (System_Status.Upper_Temp_Limit <= Absolute_Max_Temp);
   
   
   procedure ReadCurrentTemp with
     Global => (In_Out => (Standard_Output, Standard_Input, System_Status)),
     Depends => (Standard_Output => (Standard_Output, Standard_Input, System_Status),
                 Standard_Input  => (Standard_Input, System_Status),
                 System_Status   => (System_Status, Standard_Input));
   
   
   procedure GetSystemMethod with
     Global => (In_Out => (Standard_Output, Standard_Input, System_Status)),
     Depends => (Standard_Output => (Standard_Output, Standard_Input),
                 Standard_Input  => (Standard_Input),
                 System_Status   => (System_Status, Standard_Input)),
     Post => (System_Status.System_Method = Automatic) or
             (System_Status.System_Method = Manual);
   
   
   procedure ControlTemp with
     Global => (In_Out => (Standard_Output, System_Status)),
     Depends => (Standard_Output => (System_Status, Standard_Output),
                 System_Status => (System_Status)),
     Pre => (System_Status.Current_Temp <= (Integer'Last/2)) and
            (System_Status.Lower_Temp_Limit <= (Integer'Last/2)) and
            (System_Status.Upper_Temp_Limit <= (Integer'Last/2)),
     Post => (System_Status.Current_Temp = System_Status.Current_Temp'Old + System_Status.Temp_Control) and
             (System_Status.Gain_Divisor = System_Status.Gain_Divisor'Old) and
             (System_Status.Current_Temp >= Integer'First and System_Status.Current_Temp <= System_Status.Current_Temp);
   
   
   procedure PrintTempStatus with
     Global => (In_Out => Standard_Output,
                Input => System_Status),
     Depends => (Standard_Output => (System_Status, Standard_Output));
   
   
   function isComplete return Boolean with
     Depends => (isComplete'Result => System_Status);
   
   
   procedure Init with 
     Global => (Output => (Standard_Output, Standard_Input, System_Status)),
     Depends => ((Standard_Output, Standard_Input, System_Status) => null),
     Post => (System_Status.Is_Initialised);
   

end Temperature_Control_System;
