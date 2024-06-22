import { YoutubePopover } from "./components/popovers/Youtube/youtube";
import Clock from "./components/tiles/Clock/clock";
import { getMirrorConfig } from "./shared/utils/mirror-config";

export default function Home() {
  const mirrorConfig = getMirrorConfig();

  const { tilesX, tilesY, rotateInterfaceDegrees } = mirrorConfig;

  const shouldRotateClass = rotateInterfaceDegrees ? `rotate-[${rotateInterfaceDegrees}]` : '';

  const gridItems = Array.from({ length: tilesX * tilesY }, (_, index) => (
    <div key={index} className={`grid-item border border-gray-400 ${index === 0 ? 'col-span-2' : ''}`}>
      {index === 0 && <Clock />} {/* Display the clock only in the first grid item */}
    </div>
  ));

  return (
    <main
      className={`grid w-full h-screen p-24${shouldRotateClass}`}
      style={{
        gridTemplateColumns: `repeat(${tilesX}, 1fr)`,
        gridTemplateRows: `repeat(${tilesY}, 1fr)`,
      }}
    >
      { gridItems }

      <YoutubePopover />
  </main>
  );
}
