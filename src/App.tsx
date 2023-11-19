import "./App.css";
import { FC, useEffect, useState } from "react";

import NoFile from "./components/no-file/NoFile";
import SideBar from "./components/sidebar/SideBar";
import SourceEditor from "./components/source-editor/SourceEditor";
import TitleBar from "./components/title-bar/TitleBar";
import ViewEditor from "./components/view-editor/ViewEditor";

const App: FC = () => {
  // TODO uncomment
  // const [openFiles, setOpenFiles] = useState<Array<string>>([]);
  // const [activeFileIndex, setActiveFileIndex] = useState<number>(-1);
  const [openFiles, setOpenFiles] = useState<Array<string>>(["test 01"]);
  const [activeFileIndex, setActiveFileIndex] = useState<number>(0);

  const [mode, setMode] = useState<"source" | "view">("view");

  useEffect(() => {
    // update activeFileIndex when openFiles changes
    if (openFiles.length > 0) {
      setActiveFileIndex(openFiles.length - 1);
    } else {
      setActiveFileIndex(-1);
    }
  }, [openFiles]);

  return (
    <div>
      <TitleBar
        openFiles={openFiles}
        setOpenFiles={setOpenFiles}
        activeFileIndex={activeFileIndex}
        setActiveFileIndex={setActiveFileIndex}
      />
      <SideBar />
      {activeFileIndex === -1 ? (
        <NoFile />
      ) : mode === "view" ? (
        <ViewEditor
          title={openFiles[activeFileIndex]}
          setTitle={(title: string) => {
            const newOpenFiles = [...openFiles];
            newOpenFiles[activeFileIndex] = title;
            setOpenFiles(newOpenFiles);
          }}
          setMode={setMode}
        />
      ) : (
        <SourceEditor
          title={openFiles[activeFileIndex]}
          setTitle={(title: string) => {
            const newOpenFiles = [...openFiles];
            newOpenFiles[activeFileIndex] = title;
            setOpenFiles(newOpenFiles);
          }}
          setMode={setMode}
        />
      )}
    </div>
  );
};

export default App;
