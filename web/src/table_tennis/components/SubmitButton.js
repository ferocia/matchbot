import React, { useState } from "react";
import { gql, useMutation } from "@apollo/client";
import { Button, useToast } from "@chakra-ui/react";
import { isValidState } from "../helper";
import { useGameDispatch, useGameState } from "../GameContext";

const SUBMIT_RESULT = gql`
  mutation SubmitResult($gameId: ID!, $results: [MatchResult!]!) {
    createMatch(gameId: $gameId, results: $results, postResultToSlack: true) {
      match {
        id
        text
      }
    }
  }
`;

const SubmitButton = ({ gameId }) => {
  const [submitting, setSubmitting] = useState(false);
  const toast = useToast();
  const dispatch = useGameDispatch();
  const state = useGameState();
  const [submitResult] = useMutation(SUBMIT_RESULT);

  const handleResultSubmission = () => {
    if (!isValidState(state)) {
      toast.closeAll();
      toast({
        title: "Invalid input",
        description: "Please enter players and valid score result.",
        status: "error",
        duration: 4000,
        isClosable: true,
        position: "top",
      });
      return false;
    }

    setSubmitting(true);
    const toSubmit = [
      {
        players: [state.team1.player1, state.team1.player2].filter(Boolean),
        score: state.team1.score,
        place: state.team1.score > state.team2.score ? 1 : 2,
      },
      {
        players: [state.team2.player1, state.team2.player2].filter(Boolean),
        score: state.team2.score,
        place: state.team2.score > state.team1.score ? 1 : 2,
      },
    ];

    submitResult({ variables: { gameId: gameId, results: toSubmit } })
      .then((response) => {
        setSubmitting(false);
        dispatch({ type: "game_submitted" });
        toast.closeAll();
        toast({
          title: "Result submitted.",
          description: response.data.createMatch.match.text,
          status: "success",
          duration: 10000,
          isClosable: true,
          position: "top",
        });
      })
      .catch((e) => {
        setSubmitting(false);
        toast.closeAll();
        toast({
          title: "Submit failed.",
          description: e.message,
          status: "error",
          duration: 10000,
          isClosable: true,
          position: "top",
        });
      });
  };

  return (
    <Button
      onClick={handleResultSubmission}
      colorScheme="green"
      mt="15"
      isDisabled={submitting}
    >
      Submit
    </Button>
  );
};

export default SubmitButton;
