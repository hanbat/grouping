class UnionFind
  def initialize
    @components = {}
    @size = {}
  end

  def find(p)
    @components[p] == p ? p : find(@components[p])
  end

  def union(p, q)
    return if connected?(p, q)

    root_p, root_q = find(p), find(q)
    @size[root_p] > @size[root_q] ? join(root_q, root_p) : join(root_p, root_q)
  end

  def add(p)
    @components[p] ||= p
    @size[p] ||= 1
  end

  private

  def connected?(p, q)
    find(p) == find(q)
  end

  def join(root_1, root_2)
    @components[root_1] = root_2
    @size[root_2] += @size[root_1]
  end
end