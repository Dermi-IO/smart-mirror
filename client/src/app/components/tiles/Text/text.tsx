import React from "react"
import Markdown from 'react-markdown';


const Text: React.FC<{markdown: string}> = ({markdown}) => {
  return (
    <div className="text-white text-4xl font-bold" data-testid="clock-tile">
        <Markdown>{markdown}</Markdown>
    </div>
  )
}

export default Text;