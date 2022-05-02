%%%
%%%   Name:               Containers.oz
%%%
%%%   Started:            Tue Feb 22 09:37:23 2022
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
class Container
   meth size($)
      raise 'Abstract method' end
   end
   meth isEmpty($)
      raise 'Abstract method' end
   end
   % meth clear
   %    raise 'Abstract method' end
   % end
end
class Dispenser from Container
end
class Node
   attr first rest
   meth init(First Rest)
      first := First
      rest := Rest
   end
   meth first($)
      @first
   end
   meth setFirst(H)
      first := H
   end
   meth rest($)
      @rest
   end
   meth setRest(T)
      rest := T
   end
   meth spliceBefore(O)
      local
         Copy = {New Node init(@first @rest)}
      in
         first := O
         rest := Copy
      end
   end
   meth spliceAfter(O)
      local
         Rest = {New Node init(O @rest)}
      in
         {self setRest(Rest)}
      end
   end
   meth exciseNode($)
      local
         Doomed = @first
         Saved = @rest
      in
         if Saved == nil then
            raise 'Target node must have non-nil next node' end
         else
            {self setFirst({Saved first($)})}
            {self setRest({Saved rest($)})}
         end

         Doomed
      end
   end
   meth exciseChild($)
      local
         Child = @rest
      in
         if Child == nil then
            raise 'Parent must have child node' end
         else
            {self setRest({Child rest($)})}
         end

         {Child first($)}
      end
   end
   %%
   %%    Should be class method (like all of the other implementations?!)?
   %%    
   % meth nth(N $)
   %    if N == 0 orelse {self rest($)} == nil then
   %       {self first($)}
   %    else
   %       {{self rest($)} nth(N-1 $)}
   %    end
   % end
   meth nth(N $)
      if N == 0 orelse @rest == nil then
         @first
      else
         {@rest nth(N-1 $)}
      end
   end
   meth setNth(N O)
      if N == 0 then
         first := O
      elseif @rest == nil then
         raise 'Invalid index' end
      else
         {@rest setNth(N-1 O)}
      end
   end
   %%
   %%    Should be class method (like all of the other implementations?!)?
   %%    
   meth nthCdr(N $)
      if N == 0 orelse {self rest($)} == nil then
         self
      else
         {{self rest($)} nthCdr(N-1 $)}
      end
   end
   meth contains(N O $)
      if N == nil then false
      elseif {N first($)} == O then {N first($)}
      else Node,contains({N rest($)} O $)
      end
   end
   meth browse
      {Browse @first|@rest}
   end
end
class Collection from Container
   meth iterator($)
      raise 'Abstract method' end
   end
   meth contains(O $) % test
      raise 'Abstract method' end
   end
   % meth equals(C $) % test
   %    raise 'Abstract method' end
   % end
   meth each(F)
      raise 'Abstract method' end
   end
end
class MutableCollection from Collection
   attr modificationCount:0
   meth countModification
      modificationCount := @modificationCount + 1
   end
   meth modificationCount($)
      @modificationCount
   end
end
class RemoteControl
   attr interface
   meth init(Interface)
      interface := Interface
   end
   meth press(M $)
      {{Dictionary.get @interface M}}
   end
end
% class Iterator
%    meth current($)
%       if {self done($)} then
%          raise 'Iteration already finished' end
%       else
%          {self iterateCurrent($)}
%       end
%    end
%    meth iterateCurrent($)
%       raise 'Abstract method' end
%    end
%    meth next($)
%       raise 'Abstract method' end
%    end
%    meth done($)
%       raise 'Abstract method' end
%    end
% end
% class MutableCollectionIterator from Iterator
%    attr collection expectedModificationCount
%    meth init(C)
%       collection := C
%       expectedModificationCount := {C modificationCount($)}
%    end
%    meth comodified($)
%       @expectedModificationCount \= {@collection modificationCount($)}
%    end
%    meth iterateCurrent($)
%       if {self comodified($)} then
%          raise 'Iterator invalid due to structural modification of collection' end
%       else
%          {self doIterateCurrent($)}
%       end
%    end
%    meth doIterateCurrent($)
%       raise 'Abstract method' end
%    end
%    meth next($)
%       if {self comodified($)} then
%          raise 'Iterator invalid due to structural modification of collection' end
%       else
%          {self iterateNext($)}
%       end
%    end
%    meth iterateNext($)
%       raise 'Abstract method' end
%    end
%    meth done($)
%       if {self comodified($)} then
%          raise 'Iterator invalid due to structural modification of collection' end
%       else
%          {self iterateDone($)}
%       end
%    end
%    meth iterateDone($)
%       raise 'Abstract method' end
%    end
% end
class Iterator
   attr done curr advance
   meth init(D C A)
      done := D
      curr := C
      advance := A
   end
   meth isDone($)
      {self checkDone($)}
   end
   meth checkDone($)
      {@done}
   end
   meth current($)
      if {self isDone($)} then
         raise 'Iteration already finished' end
      else
         {self currentElement($)}
      end
   end
   meth currentElement($)
      {@curr}
   end
   meth next($)
      if {self isDone($)} then
         nil
      else
         {self nextElement}

         if {self isDone($)} then
            nil
         else
            {self current($)}
         end
      end
   end
   meth nextElement
      {@advance}
   end
end
class MutableCollectionIterator from Iterator
   attr expectedModificationCount modificationCount
   meth init(D C A M)
      Iterator,init(D C A)
      modificationCount := M
      expectedModificationCount := {@modificationCount}
   end
   meth comodified($)
      @expectedModificationCount \= {@modificationCount}
   end
   meth checkComodification
      if {self comodified($)} then
         raise 'Iterator invalid due to structural modification of collection' end
      end
   end
   meth checkDone($)
      {self checkComodification}

      Iterator,checkDone($)
   end
   meth currentElement($)
      {self checkComodification}

      Iterator,currentElement($)
   end
   meth nextElement
      {self checkComodification}

      Iterator,nextElement
   end
end
