'use client'

import React, { ReactNode, useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faUpRightAndDownLeftFromCenter } from '@fortawesome/free-solid-svg-icons';

interface PopoverProps {
  children: ReactNode;
  minWidth: number;
  minHeight: number;
}

export const Popover: React.FC<PopoverProps> = ({ children, minWidth, minHeight }) => {
  const [position, setPosition] = useState({ top: 100, left: 100 });
  const [size, setSize] = useState({ width: minWidth, height: minHeight });
  const [isDragging, setIsDragging] = useState(false);
  const [isResizing, setIsResizing] = useState(false);
  const [initialPosition, setInitialPosition] = useState({ x: 0, y: 0 });
  const [initialSize, setInitialSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (isDragging) {
        setPosition({
          top: e.clientY - initialPosition.y,
          left: e.clientX - initialPosition.x,
        });
      }
      if (isResizing) {
        const newWidth = initialSize.width + (e.clientX - initialPosition.x);
        const newHeight = initialSize.height + (e.clientY - initialPosition.y);

        setSize({
          width: newWidth > minWidth || newWidth > initialSize.width ? newWidth : minWidth,
          height: newHeight > minHeight || newHeight > initialSize.height ? newHeight : minHeight,
        });
      }
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      setIsResizing(false);
      document.removeEventListener("mousemove", handleMouseMove);
      document.removeEventListener("mouseup", handleMouseUp);
    };

    if (isDragging || isResizing) {
      document.addEventListener("mousemove", handleMouseMove);
      document.addEventListener("mouseup", handleMouseUp);
    }

    return () => {
      document.removeEventListener("mousemove", handleMouseMove);
      document.removeEventListener("mouseup", handleMouseUp);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isDragging, isResizing, initialPosition, initialSize]);

  const handleMouseDown = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    e.preventDefault();
    const targetClassList = (e.target as HTMLElement).classList;
    if (targetClassList.contains("floating-div")) {
      setInitialPosition({
        x: e.clientX - position.left,
        y: e.clientY - position.top,
      });
      setIsDragging(true);
    } else if (targetClassList.contains("resize-handle")) {
      setInitialSize({
        width: size.width,
        height: size.height,
      });
      setInitialPosition({
        x: e.clientX,
        y: e.clientY,
      });
      setIsResizing(true);
    }
  };

  return (
    <div
      className="floating-div absolute bg-blue-500 text-white p-4 cursor-move"
      style={{ top: position.top, left: position.left, width: size.width, height: size.height }}
      onMouseDown={handleMouseDown}
    >
      <div className="resize-handle absolute right-0 bottom-0 w-10 h-10 cursor-nwse-resize">
        <FontAwesomeIcon icon={faUpRightAndDownLeftFromCenter} flip="horizontal" className="text-black" />
      </div>
      {children}
    </div>
  );
};
