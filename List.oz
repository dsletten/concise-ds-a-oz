%%%
%%%   Name:               List.oz
%%%
%%%   Started:            Thu Feb 24 10:34:56 2022
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
fun {Mod M N}
   Rem = M mod N
in
   if Rem \= 0 andthen if M < 0 then N > 0 else N < 0 end then
      N + Rem
   else Rem
   end
end
class List from Collection
   attr fillElt:nil
   meth init(Fill)
      fillElt := Fill
   end
   meth equals(L $) % test
      local
         fun {Compare I1 I2}
            if {I1 isDone($)} andthen {I2 isDone($)} then
               true
            elseif {I1 current($)} \= {I2 current($)} then
               false
            else
               {I1 next(_)}
               {I2 next(_)}
               {Compare I1 I2}
            end
         end
      in
         if {self size($)} == {L size($)} then
            {Compare {self iterator($)} {L iterator($)}}
         else
            false
         end
      end
   end
%    meth add(Os)
% %   meth add(O|Or)
%       raise "Abstract method" end
%    end
%    meth extendList(I O)
%       {Procedure.apply add 
% (defun extend-list (list i obj)
%   (apply #'add list (loop repeat (1+ (- i (size list)))
%                           for tail = (cl:list obj) then (cons (fill-elt list) tail)
%                           finally (return tail))))
   meth extendList(I O)
      local
         fun {Extend N Result}
            if N == 0 then
               Result
            else
               {Extend N-1 @fillElt|Result}
            end
         end
      in
         {self add({Extend I-{self size($)} [O]})}
      end
   end
   meth insert(I O)
      if I < 0 then
         local
            J = I + {self size($)}
         in
            if J >= 0 then
               {self insert(J O)}
            end
         end
      elseif I > {self size($)} then
         {self extendList(I O)}
      else
         {self insertList(I O)}
      end
   end
   meth get(I $)
      if I < 0 then
         local
            J = I + {self size($)}
         in
            if J < 0 then
               nil
            else
%               {self getElt(J $)}
               {self get(J $)}
            end
         end
      elseif I >= {self size($)} then
         nil
      else
         {self getElt(I $)}
      end
   end
   meth getElt(I $)
      raise "Abstract method" end
   end
   meth set(I O)
      if I < 0 then
         local
            J = I + {self size($)}
         in
            if J >= 0 then
               {self set(J O)}
            end
         end
      elseif I >= {self size($)} then
         {self extendList(I O)}
      else
         {self setElt(I O)}
      end
   end
   meth setElt(I O)
      raise "Abstract method" end
   end
   meth show
      local
         proc {PrintList I}
            if {Not {I isDone($)}} then
               {System.print ' '}
               {System.print {I current($)}}
               {I next(_)}
               {PrintList I}
            end
         end
      in
         {System.print '('}
         if {Not {L isEmpty($)}} then
            local
               I = {self iterator($)}
            in
               {System.print {I current($)}}
               {I next(_)}
               {PrintList I}
            end
         end
         {Show ')'}
      end
   end
end
class MutableList from MutableCollection List
   % meth equals
   %    skip
   % end
   meth clear
      {self countModification}
      {self clearList}
   end
   meth clearList
      raise "Abstract method" end
   end
   meth add(Os)
      case Os
      of nil then skip
      else
         {self countModification}
         {self addElt(Os)}
      end
   end
   meth addElt(Os)
      raise "Abstract method" end
   end
   meth insertList(I O)
      {self countModification}
      {self doInsertList(I O)}
   end
% (defmethod delete :after ((l mutable-list) (i integer))
%   (declare (ignore i))
%   (count-modification l))
end
class MutableLinkedList from MutableList
   meth insertBefore(N O)
      if {self isEmpty($)} then
         raise "List is empty" end
      elseif N == nil then
         raise "Invalid node" end
      else
         {self insertListBefore(N O)}
      end
   end
   meth insertListBefore(N O)
      {self countModification}
      {self doInsertListBefore(N O)}
   end
   meth insertAfter(N O)
      if {self isEmpty($)} then
         raise "List is empty" end
      elseif N == nil then
         raise "Invalid node" end
      else
         {self insertListAfter(N O)}
      end
   end
   meth insertListAfter(N O)
      {self countModification}
      {self doInsertListAfter(N O)}
   end
   meth deleteNode(N $)
      if {self isEmpty($)} then
         raise "List is empty" end
      elseif N == nil then
         raise "Invalid node" end
      else
         {self deleteListNode(N $)}
      end
   end
   meth deleteListNode(N $)
      {self countModification}
      {self doDeleteListNode(N $)}
   end
   meth deleteChild(N $)
      if {self isEmpty($)} then
         raise "List is empty" end
      elseif N == nil then
         raise "Invalid node" end
      else
         {self deleteListChild(N $)}
      end
   end
   meth deleteListChild(N $)
      {self countModification}
      {self doDeleteListChild(N $)}
   end
end   
class ArrayList from MutableList
   attr store:{NewArray 0 19 nil} offset:0 count:0


   meth front($) % For iterator. Should be private.
      @front
   end
   meth size($)
      @count
   end
   meth isEmpty($)
      @count == 0
   end
   meth clearList
      offset := 0
      count := 0
   end
   % meth iterator($)
   %    {New RandomAccessListIterator init(self)}
   % end
   meth addElt(Os)
      proc {AddNodes Os}
         case Os
         of nil then skip
         [] O|Or then
            local
               N = {New Node init(O nil)}
            in
               {@rear setRest(N)}
               rear := N

               {AddNodes Or}
            end
         end
      end
   in
      if {self isEmpty($)} then
         local
            O|Or = Os
         in
            front := {New Node init(O nil)}
            rear := @front
            {AddNodes Or}
         end
      else
         {AddNodes Os}
      end
      count := @count + {Length Os}
   end
   meth doInsertList(I O)
      local
         Node = {@front nthCdr(I $)}
      in
         {Node spliceBefore(O)}

         if Node == @rear then
            rear := {@rear rest($)}
         end

         count := @count + 1
      end
   end
   meth getElt(I $)
      {@front nth(I $)}
   end

   meth equals(L $) % test
      local
         fun {Compare I1 I2}
            if {I1 isDone($)} andthen {I2 isDone($)} then
               true
            elseif {I1 current($)} \= {I2 current($)} then
               false
            else
               {I1 next(_)}
               {I2 next(_)}
               {Compare I1 I2}
            end
         end
      in
         if {self size($)} == {L size($)} then
            {Compare {self iterator($)} {L iterator($)}}
         else
            false
         end
      end
   end


end
class SinglyLinkedList from MutableLinkedList
   attr front:nil rear:nil count:0
   meth front($) % For iterator. Should be private.
      @front
   end
   meth size($)
      @count
   end
   meth isEmpty($)
      @front == nil
   end
   meth clearList
      front := nil
      rear := nil
      count := 0
   end
   meth equals(L $) % test
      local
         fun {Compare I1 I2}
            if {I1 isDone($)} andthen {I2 isDone($)} then
               true
            elseif {I1 current($)} \= {I2 current($)} then
               false
            else
               {I1 next(_)}
               {I2 next(_)}
               {Compare I1 I2}
            end
         end
      in
         if {self size($)} == {L size($)} then
            {Compare {self iterator($)} {L iterator($)}}
         else
            false
         end
      end
   end
   % meth iterator($)
   %    {New SinglyLinkedListIterator init(self)}
   % end
   meth iterator($)
      local
         Cursor = {NewCell @front}
      in
         {New MutableCollectionIterator init(fun {$} @Cursor == nil end
                                             fun {$} {@Cursor first($)} end
                                             proc {$} Cursor := {@Cursor rest($)} end
                                             fun {$} {self modificationCount($)} end)}
      end
   end
%   meth contains(Obj $)
   meth addElt(Os)
      proc {AddNodes Os}
         case Os
         of nil then skip
         [] O|Or then
            local
               N = {New Node init(O nil)}
            in
               {@rear setRest(N)}
               rear := N

               {AddNodes Or}
            end
         end
      end
   in
      if {self isEmpty($)} then
         local
            O|Or = Os
         in
            front := {New Node init(O nil)}
            rear := @front
            {AddNodes Or}
         end
      else
         {AddNodes Os}
      end
      count := @count + {Length Os}
   end
   meth doInsertList(I O)
      local
         Node = {@front nthCdr(I $)}
      in
         {Node spliceBefore(O)}

         if Node == @rear then
            rear := {@rear rest($)}
         end

         count := @count + 1
      end
   end
   meth doInsertListBefore(N O)
      {N spliceBefore(O)}

      if Node == @rear then
         rear := {@rear rest($)}
      end

      count := @count + 1
   end
   meth doInsertListAfter(N O)
      {N spliceAfter(O)}

      if Node == @rear then
         rear := {@rear rest($)}
      end

      count := @count + 1
   end
   meth delete(I $)
      if I == 0 then
         local
            Doomed = {@front first($)}
         in
            front := {@front rest($)}
            if @front == nil then
               rear := nil
            end

            count := @count - 1
            Doomed
         end
      else
         local
            Parent = {@front nthCdr(I-1 $)}
            Child = {Parent exciseChild($)}
         in
            if {Parent rest($)} == nil then
               rear := Parent
            end

            count := @count - 1
            Child
         end
      end
   end
   meth deleteNode(N $)
      if N == @front then
         local
            Doomed = {@front first($)}
         in
            front := {@front rest($)}
            if @front == nil then
               rear := nil
            end

            count := @count - 1
            Doomed
         end
      else
         local
            Doomed = {N exciseNode($)}
         in
            if {N rest($)} == nil then
               rear := N
            end
            
            count := @count - 1
            Doomed
         end
      end
   end
   meth deleteChild(P $)
      local
         Child = {P exciseChild($)}
      in
         if {P rest($)} == nil then
            rear := P
         end

         count := @count - 1
         Child
      end
   end
   meth getElt(I $)
      {@front nth(I $)}
   end
   meth setElt(I O)
      {@front setNth(I O)}
   end
end
class SinglyLinkedListIterator from MutableCollectionIterator
   attr cursor
   meth init(C)
      MutableCollectionIterator,init(C)
      cursor := {C front($)}
   end
   meth doIterateCurrent($)
      {@cursor first($)}
   end
   meth iterateNext($)
      if {self isDone($)} then
         nil
      else
         cursor := {@cursor rest($)}
         if {self isDone($)} then
            nil
         else
            {self current($)}
         end
      end
   end
   meth iterateDone($)
      @cursor == nil
   end
end
class Dcons
   attr previous:nil content:nil next:nil
   meth init(C)
      content := C
   end
   meth previous($)
      @previous
   end
   meth setPrevious(D)
      previous := D
   end
   meth content($)
      @content
   end
   meth setContent(C)
      content := C
   end
   meth next($)
      @next
   end
   meth setNext(D)
      next := D
   end
   meth link(D)
      {self setNext(D)}
      {D setPrevious(self)}
   end
   meth spliceBefore(O)
      local
         NewDcons = {New Dcons init(O)}
      in
         {{self previous($)} link(NewDcons)}
         {NewDcons link(self)}
      end
   end
   meth spliceAfter(O)
      local
         NewDcons = {New Dcons init(O)}
      in
         {NewDcons link({self next($)})}
         {self link(NewDcons)}
      end
   end
   meth exciseNode($)
      if self == {self next($)} then
         raise "Cannot delete sole node." end
      else
         {{self previous($)} link({self next($)})}
      end

      {self content($)}
   end
   meth exciseChild($)
      local
         Child = {self next($)}
      in
         if self == Child then
            raise "Parent must have child node" end
         else
            {self link({Child next($)})}
         end

         {Child content($)}
      end
   end
   meth print
      {System.print '<'}
      {self printPrevious}
      {System.print @content}
      {self printNext}
      {Show '>'}
   end
   meth printPrevious
      if @previous == nil then
         {System.print 'X <- '}
      elseif self == @previous then
         {System.print '<-> '}
      else
         {System.print {@previous content($)}}
         {System.print ' <- '}
      end
   end
   meth printNext
      if @next == nil then
         {System.print ' -> X'}
      elseif self == @next then
         {System.print ' <->'}
      else
         {System.print ' -> '}
         {System.print {@next content($)}}
      end
   end
end
class Dcursor
   attr list:nil node:nil index:0
   meth init(L)
      list := L
      node := {@list store($)}
   end
   meth isInitialized($)
      @node \= nil
   end
   meth reset
      node := {@list store($)}
      index := 0
   end
   meth isAtStart($)
      {Not {self isInitialized($)}} orelse @index == 0
   end
   meth isAtEnd($)
      {Not {self isInitialized($)}} orelse @index == {@list size($)}-1
   end
   meth advance(Step) % optional...
      if {Not {self isInitialized($)}} then
         raise "Cursor has not been initialized" end
      elseif Step < 0 then
         raise "Step must be a positive value: " end % step...
      else
         for I in 1..Step do
            index := @index + 1
            node := {@node next($)}
         end

         index := {Mod @index {@list size($)}}
      end
   end
   meth rewind(Step) % optional...
      if {Not {self isInitialized($)}} then
         raise "Cursor has not been initialized" end
      elseif Step < 0 then
         raise "Step must be a positive value: " end % step...
      else
         for I in 1..Step do
            index := @index - 1
            node := {@node previous($)}
         end

         index := {Mod @index {@list size($)}}
      end
   end
   meth bump
      if {Not {self isInitialized($)}} then
         raise "Cursor has not been initialized" end
      else
         node := {@node next($)}
      end
   end
end
%class DoublyLinkedList from 