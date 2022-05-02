%%%
%%%   Name:               Queue.oz
%%%
%%%   Started:            Wed Feb 23 09:50:00 2022
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
class Queue from Dispenser
   meth init
      skip
   end
   meth isEmpty($)
      {self size($)} == 0
   end
   meth enqueue
      skip
   end
   meth dequeue($)
      if {self isEmpty($)} then
         raise "Empty queue" end
      else
         {self dequeueQueue($)}
      end
   end
   meth front($)
      if {self isEmpty($)} then
         raise "Empty queue" end
      else
         {self frontQueue($)}
      end
   end
end
class LinkedQueue from Queue
   attr front:nil rear:nil count:0
   meth size($)
      @count
   end
   meth clear
      front := nil
      rear := nil
      count := 0
   end
   meth enqueue(O)
      local
         N = {New Node init(O nil)}
      in
         if {self isEmpty($)} then
            front := N
         else
            {@rear setTail(N)}
         end

         rear := N
      end
      count := @count + 1
   end
   meth dequeueQueue($)
      local
         Discard = {self front($)}
      in
         front := {@front tail($)}

         if @front == nil then
            rear := nil
         end
         
         count := @count - 1
         Discard
      end
   end
   meth frontQueue($)
      {@front head($)}
   end
end

   