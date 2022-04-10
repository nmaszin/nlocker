def to_list(func):
    return lambda *a, **kw: list(func(*a, **kw))

