local _, _addon = ...

isDevelopment = false;

function devPrint(...) if (isDevelopment) then print(...) end end
