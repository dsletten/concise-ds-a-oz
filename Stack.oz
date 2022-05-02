%%%
%%%   Name:               Stack.oz
%%%
%%%   Started:            Tue Feb 22 09:41:46 2022
%%%   Modifications:
%%%
%%%   Purpose:
%%%
%%%
%%%
%%%   Calling Sequence:
%%%
%%%
%%%   Inputs:
%%%
%%%   Outputs:
%%%
%%%   Example:
%%%
%%%   Notes:
%%%
%%%

declare
class Stack from Dispenser
   meth init
      skip
   end
   meth push
      skip
   end
   meth pop
      if {self isEmpty($)} then
         raise "Empty stack" end
      else
         {self popStack}
      end
   end
   meth peek($)
      if {self isEmpty($)} then
         raise "Empty stack" end
      else
         {self peekStack($)}
      end
   end
   % meth peekStack($)
   %    nil
   % end
end
class LinkedStack from Stack
   attr top:nil count:0
   meth size($)
      @count
   end
   meth isEmpty($)
      @top == nil
   end
   meth clear
      top := nil
      count := 0
   end
   meth push(O)
      top := O|@top
      count := @count + 1
   end
   meth popStack
      top := @top.2
      count := @count - 1
   end
   meth peekStack($)
      @top.1
   end
end

   