'use client'

import React, { ReactNode, useEffect, useState } from "react";

interface PopoverProps {
  children: ReactNode;
  minWidth: number;
  minHeight: number;
}

export const Popover: React.FC<PopoverProps> = ({ children, minWidth, minHeight }) => {
  const popoverPadding = 20;

  const [size,] = useState({ width: minWidth, height: minHeight });
  const [position, setPosition] = useState({ top: -999, left: -999});

  // TODO: Decide if this should be movable or not ? i.e snap-to-[loc] via voice
  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => {
    setPosition({
      top: window.innerHeight - size.height - popoverPadding,
      left: window.innerWidth - size.width - popoverPadding,
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div
      className="floating-div absolute bg-black text-white p-0 cursor-move"
      style={{ top: position.top, left: position.left, width: size.width, height: size.height }}
    >
      {children}
    </div>
  );
};
