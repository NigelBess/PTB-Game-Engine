function out = GetKey(keyName)
out = false;
[bool,~,code,~] = KbCheck();
if ~bool return; end
key = KbName(code);
out = sum(strcmpi(key,keyName));
end