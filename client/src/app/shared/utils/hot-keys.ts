import React, { useEffect } from 'react';
import hotkeys, { KeyHandler } from 'hotkeys-js';

export interface IReactHotkeysProps {
    keyName: string;
    handler: KeyHandler;
    disabled?: boolean;
    splitKey?: string;
    scope?: string;
    children?: React.ReactNode;
}

const ReactHotKeys: React.FC<IReactHotkeysProps> = ({keyName, handler, disabled, splitKey, scope, children}: IReactHotkeysProps) => {
    useEffect(() => {
        if(disabled)
        {
            hotkeys.unbind(keyName, "all", handler);
        } else {
            hotkeys(keyName, { splitKey: splitKey ?? '+', scope: scope ?? "all" } ,handler);
        }

        return () => {
            hotkeys.unbind(keyName, handler);
        };
            
    }, [keyName, disabled, handler]);
      
    return <>{children}</>;
}  

export default ReactHotKeys;