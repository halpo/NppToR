;{ NppToR: R in Notepad++
; by Andrew Redd 2011 <halpo@users.sourceforge.net>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
;
; DESCRIPTION
; ===========
; Functions for clipboard manipulations.
;
;}

ClipCore(save, wait=0)
{
    static oldclipboard =
    static last = 0
    global restoreclipboard
    if(     save AND NOT last AND restoreclipboard )
    {
        oldclipboard := clipboard
        last = 1
    }
    if( NOT save AND     last AND restoreclipboard )
    {
        sleep %wait%
        clipboard := oldclipboard
        oldclipboard = 
        last = 0
    }
    return
}

ClipSave()
{
    ClipCore(1,0)
    return
}

ClipRestore( wait=0)
{
    ClipCore(0, wait)
    return
}

