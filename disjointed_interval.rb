class DisjointedInterval
  @state = []

  def initialize
    @state = []
  end

  def state
    @state
  end

  def state=(new_state)
    @state = new_state
  end

  def potential_insertion_point(from, internal_state, to, total_length)
    from_idx = -1
    to_idx = -1

    # Loop through array to find the potential insert location
    internal_state.each_with_index do |elem, idx|
      if from_idx == -1 && from < elem
        from_idx = idx
      end

      if to_idx == -1 && to < elem
        to_idx = idx
      end

      break if from_idx != -1 && to_idx != -1
    end

    # If any of this is -1, there is nothing larger than from/to
    from_idx = total_length if from_idx == -1
    to_idx = total_length if to_idx == -1
    return from_idx, to_idx
  end

  def add(from, to)
    raise RangeError, 'Invalid interval: to <= from' if from == to || to < from

    # Flatten so we can act on it like an integer array
    internal_state = state.flatten
    total_length = internal_state.length

    if internal_state.nil? || internal_state.empty?
      internal_state = [from, to]
    end

    from_idx, to_idx = potential_insertion_point(from, internal_state, to, total_length)

    if from_idx == to_idx
      # When both smaller than first element
      if from_idx == 0 && to_idx == 0
        internal_state.insert(from_idx, from)
        internal_state.insert(to_idx + 1, to)

        # When both larger than last element
      elsif from_idx == total_length && to_idx == total_length
        # If last elem == from, to is the new last elem
        if internal_state.last == from
          internal_state[total_length - 1] = to
        else
          internal_state << from << to
        end
      end
    else

      # Intervals always starts at the even positions
      if from_idx.odd?
        from_idx -= 1
        #do nothing
      else
        # If this new interval equals to end of a previous interval, 
        # we take the start of the previous interval
        if from == internal_state[from_idx-1]
          from_idx -= 2
        elsif from < internal_state[from_idx]
          internal_state[from_idx] = from
        end
      end

      # Intervals always ends at the odd positions
      if to_idx.odd?
        if to > internal_state[to_idx]
          internal_state[to_idx] = to
        end
      else
        to_idx -= 1
        internal_state[to_idx] = to
      end
    end

    # Merge multiple intervals into 1 by deleting all elements in between the from_idx and to_idx 
    if to_idx - from_idx > 1
      (to_idx-1).downto(from_idx+1).each do |idx|
        internal_state.delete_at(idx)
      end
    end

    @state = internal_state.each_slice(2).to_a
  end

  def remove(from, to)
    remove_inclusive(from+1, to-1)
  end

  def remove_inclusive(from, to)
    raise RangeError, 'Invalid interval: to <= from' if to < from

    # Flatten so we can act on it like an integer array
    internal_state = state.flatten
    total_length = internal_state.length

    # Do nothing if state is empty
    return if state.empty?

    from_idx, to_idx = potential_insertion_point(from, internal_state, to, total_length)

    if from_idx == to_idx

      # When both smaller than start interval or when both larger than end interval
      if (from_idx == 0 && to_idx == 0) ||
          (from_idx == total_length && to_idx == total_length)

        # If the last value is equivalent to from, 
        # we need to decrement it by 1
        if (internal_state[from_idx - 1] == from)
          internal_state[from_idx - 1] = from - 1
        end
      end

      if from_idx.odd?
        internal_state.insert(to_idx, to + 1)
        internal_state.insert(from_idx, from - 1)
      else
        #Ignore and do nothing because it is in between intervals
      end

      @state = post_removal_cleanup(internal_state)

      return

      # If this interval covers everything
    elsif from_idx == 0 && to_idx >= total_length
      @state = []

      return
    else
      if from_idx.odd?
        internal_state[from_idx] = from - 1

      else
        # If the last value is equivalent to from, 
        # we need to decrement it by 1
        if from_idx >= 1 && (internal_state[from_idx - 1] == from)
          from_idx -= 1

          internal_state[from_idx] = from - 1
        end
      end

      # Do nothing at an even index because it is between intervals 
      if to_idx.odd?
        internal_state[to_idx - 1] = to + 1
      end

      # Delete elements between from_idx and to_idx because 
      # they are within the requested deletion interval
      # However, only do this if end is in an end position (even)
      if to_idx.even? && to_idx - from_idx > 1
        (to_idx - 1).downto(from_idx + 1).each do |idx|
          internal_state.delete_at(idx)
        end
      end
    end

    @state = post_removal_cleanup(internal_state)
  end

  # If any of the end interval element is less than or equal to 
  # the start interval element, we remove it
  def post_removal_cleanup(internal_state)
    state = internal_state.each_slice(2).to_a

    state.delete_if { |a| a[1] <= a[0] }

    state
  end
end
