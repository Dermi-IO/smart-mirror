'use client'

import { useEffect, useState } from "react";
import { Popover } from "../pop-over";
import hotkeys from 'hotkeys-js';


export const YoutubePopover: React.FC = () => {
    const [show, setShow] = useState(false);
    
    const toggleShow = () => setShow(prevShow => !prevShow);

    const hotKey = 'alt+y';

    useEffect(() => {
        hotkeys(hotKey, function (event) {
            if(event.type === 'keydown'){
                toggleShow();
            } 
        });
        
        return () => {
            hotkeys.unbind(hotKey);
        }
    }, []);

   return (
        show && <Popover minWidth={600} minHeight={400}>
            <iframe width="600" height="400" src="https://www.youtube.com/embed/cIpLibg_uqM?si=p4J5lB-WLCBPyp0s&controls=0&autoplay=1&mute=1" title="DermDoctor" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerPolicy="strict-origin-when-cross-origin" className="mt-0"></iframe>
        </Popover>
   );
}