from ansible import errors
import re

def split_string(string, seperator=' '):
    try:
        return string.split(seperator)
    except Exception, e:
        raise errors.AnsibleFilterError('split plugin error: %s, string=%s' % str(e),str(string) )

def split_regex(string, seperator_pattern):
    try:
        return re.split(seperator_pattern, string)
    except Exception, e:
        raise errors.AnsibleFilterError('split plugin error: %s' % str(e))

def split_get_index(array, index):
    try:
        return array[index]
    except Exception, e:
        raise errors.AnsibleFilterError('split plugin error: %s, index=%s' % str(e),str(index))

class FilterModule(object):
    ''' A filter to split a string into a list. '''
    def filters(self):
        return {
            'split' : split_string,
            'split_regex' : split_regex,
            'split_get_index': split_get_index
        }
